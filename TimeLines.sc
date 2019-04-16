	/*
	Contents:
	  * 1. Boot up
	  * 2. Initialization
	  * 3. Update loop
	  * 4. Resetting
	  * 5. Patching
	*/


TimeLines {
	var <numChannels, <server;
	var <sessionMode = 'FiniteMode';
	var <sessionType, <timerOn;
	var <bufferDict, <synthDict, <inputBusDict/*, <synthdefDict*/;
	var <buffersToFree;
	var <timerGroup, <synthGroup, <postSynthGroup;
	var <windowDur = 0.5, <loop = 1;
	var <ghcAddress;
	var <mainOutputBus, <silencerBus, <timerBus, <activateBufsTriggerBus;
	var <synthFadeInTime = 1, <synthFadeOutTime = 1;
	var <timerSynth, <silencerSynth, <limiterSynth, <reverbSynth, <compressorSynth;
	var <>b_debugging = false;
	var <cmdPeriodFunc;

	////////////////////////////////////////////////////////////////////////////////////
	// 1. Boot up

	*start { |numChannels = 2, server|
		~timelines.free;
		//Use default server if one is not supplied
		server = server ? Server.default;

		server.waitForBoot {
			Routine.run {
				"Booting TimeLines...".postln;
				~timelines = TimeLines(numChannels, server);
				//ServerTree.add(TimeLines.start, server);
				server.sync;
				"TimeLines: Initialization completed successfully\nListening on port %\n".format(NetAddr.langPort).postln;
			}
		};

		CmdPeriod.add(this);
		server.latency = 0.1;
	}

	*new { |numChannels = 2, server|
		^super.newCopyArgs(numChannels, server ? Server.default).init;
	}


	////////////////////////////////////////////////////////////////////////////////////
	// 2. Initialisation

	//Initializing variables, loading defs and preparing the server
	init {
		this.initCoreVariables;
		this.loadDefs;
		server.sync;
		this.startCoreSynths;

	}

	initCoreVariables {
		mainOutputBus = 0;
		timerBus= Bus.audio(server, 1);
		silencerBus = Bus.audio(server, 1);
		activateBufsTriggerBus = Bus.audio(server, 1);

		buffersToFree = List.newClear();
		ghcAddress = NetAddr("127.0.0.1", 70000);

		bufferDict = Dictionary();
		synthDict = Dictionary();
		inputBusDict = Dictionary();
		//synthdefDict = Dictionary();

		timerGroup = Group();
		synthGroup = Group.after(timerGroup);
		postSynthGroup = Group.after(synthGroup);

		this.debugPrint("initCoreVariables");
	}

	// Load and execute all files in the defs folder
	loadDefs {
		"defs/*.scd".resolveRelative.loadPaths
	}

	// Instantiate timer and silencer synths
	startCoreSynths {
		timerSynth = Synth(\timer, [
			\dur, windowDur,
			\loopPoint, 1,
			\out, timerBus,
			\silencerBus, silencerBus,
			\activateBufsTriggerBus, activateBufsTriggerBus,
			\mute, 1 // mute by default
		], timerGroup);

		compressorSynth = Synth(\compressor, [
			\bus, mainOutputBus,
			\thresh, 0.5,
			\slopeBelow, 1,
			\slopeAbove, 1,
			\clampTime, 0.01,
			\relaxTime, 0.1
		], postSynthGroup	, \addToTail);

		reverbSynth = Synth(\reverb,  [
			\bus, mainOutputBus,
			\predelay, 0.1,
			\revtime, 1.8,
			\lpf, 4500,
			\mix, 0.15
		], postSynthGroup, \addToTail);

		silencerSynth = Synth(\silencer, [
			\timerBus, timerBus,
			\bus, mainOutputBus
		], postSynthGroup, \addToTail);

		limiterSynth = Synth(\limiter, [\bus, mainOutputBus], postSynthGroup, \addToTail);

		this.debugPrint("startCoreSynths");
	}


	////////////////////////////////////////////////////////////////////////////////////
	// 3. Update loop

	askNextBuffers {
		if(sessionMode == 'InfiniteMode', {
			ghcAddress.sendMsg("/incrementWindow", "");
			this.debugPrint("askNextBuffers");
		});
	}

	askEvalSession {
		ghcAddress.sendMsg("/evalSession", "");
		this.debugPrint("askEvalSession");
	}

	allSynthsReady { |newSynths|
		var currentSynths = synthDict.keys;
		var ready = newSynths.difference(currentSynths).size == 0;
		this.debugPrint("allSynthsReady: %".format(ready));
		^ready;
	}

	switchToInfiniteMode { |newSynthNames|
		timerSynth.set(\mute, 1);
		silencerSynth.set(\mute, 1);
		//this.askEvalSession;

		this.freeAllSynths;
		//synthDict.clear;

		fork {
			// Keep checking for all synths to be instantiated
			while(
				{ this.allSynthsReady(newSynthNames).not },
				{ 0.001.wait; }
			);

			// Then unmute timer and silencer synths and start playing
			timerSynth.set(\mute, 0);
			timerSynth.set(\t_manualTrig, 1);
			timerSynth.set(\t_manualActivateBufsTrig, 1);
			silencerSynth.set(\mute, 0);

			this.debugPrint("switchToInfiniteMode");
		};
	}

	activateReceivedBuffers {
		Routine.run {
			server.sync;

			timerSynth.set(\t_manualActivateBufsTrig, 1);
			this.debugPrint("activateReceivedBuffers");
		}
	}

	setSynthOrder { |synthOrder|
		Routine.run {
			server.sync;

			synthOrder.do({ |synthName, i|
				if(synthName !=  'mainOut', {
					if(i > 0, {
						var prevSynth = synthDict[synthOrder[i - 1]];
						synthDict[synthName].moveAfter(prevSynth)
					});
				});
			});

			this.debugPrint("setSynthOrder");
		};
	}

	setSession { |newSession|
		var newMode = newSession[0].asSymbol;
		var newSynthNames = newSession.drop(1).collect{ |i| i.asSymbol};
		var synthsToRemove = synthDict.keys.difference(newSynthNames);

		// Free synths that aren't active anymore, unless switching from infinite to finite modes
		// (which frees all synths anyway)
		if(sessionMode == 'FiniteMode' && newMode == 'InfiniteMode', {
			this.switchToInfiniteMode(newSynthNames);
		}, {
			synthsToRemove.do({ |name|
				this.freeSynth(name);
			});
		});

		sessionMode = newMode;

		this.debugPrint("setSession: %".format(newMode));
	}

	freeSynth { |synthName|
		synthDict[synthName].set(\gate, 0);
		synthDict.removeAt(synthName);
		this.debugPrint("startSynths: %".format(synthName));
	}

	freeOldBuffers {
		// Free all old buffers
		buffersToFree.do({ |b| b.free });
		buffersToFree.clear;
		//this.debugPrint("freeOldBuffers");
	}

	setMute { |x|
		timerSynth.set(\mute, x);
		silencerSynth.set(\mute, x);
		this.debugPrint("setMute: %".format(x));
	}

	// Load a synth's buffers (given as a list of paths to .wav files)
	// and update it
	loadSynthBuffers { |paths|
		var numBuffs = paths.size;
		// Get synth info shared by all buffers
		// e.g. "bass_fm_amp.wav" -> synthName = "bass"; synthDef = "fm";
		var synthInfo = paths[0].asString.split(Platform.pathSeparator).reverse[0].split($_)[[0, 1]];
		var synthName = format("%_%", synthInfo[0], synthInfo[1]).asSymbol;
		var synthDef = synthInfo[1].asSymbol;
		var synth = synthDict[synthName];

		var coreSynthArgs = [
			\out, mainOutputBus,
			\timerBus, timerBus,
			\activateBufsTriggerBus, activateBufsTriggerBus
		];

		var buffers = Dictionary();

		// First, loop over the received paths, load the buffers,
		// add them to the current buffer dictionary, and add the old one to be freed
		paths.do({ |p|
			var path = p.asString;
			// Name of buffer and parameter it's controlling, e.g. 'bass_fm' and 'amp'
			var buffName = path.split(Platform.pathSeparator).reverse[0].split($.)[0].asSymbol;
			var param = buffName.asString.split($_)[2].asSymbol;

			// Register the old buffer to be deleted when it's replaced
			buffersToFree.add(bufferDict[buffName]);

			// Read the buffer
			// once loaded add to the buffers to update the synth with
			bufferDict.add(buffName ->
				Buffer.read(server, path, action: { |b|
					buffers.add(param -> b);
					this.debugPrint("loadSynthBuffers (%), added buffer %".format(synthName, param));
				});
			);
		});

		// Using a routine for server.sync (?)
		Routine.run {
			server.sync;

			this.debugPrint("loadSynthBuffers, server sync");
			// Check if the synth already exists
			if(synth.isNil,
				{
					var argList = buffers.getPairs++coreSynthArgs;
					// each synth gets its own input bus
					inputBusDict.add(synthName -> Bus.audio(server, numChannels));
					argList = argList ++ [\input, inputBusDict[synthName]];
					// If it doesn't, instantiate it with the buffers as arguments and add it to the dictionary
					synthDict.add(synthName -> Synth(synthDef, argList, synthGroup, 'addToTail'));
				},
				{
					// If it does exist, check to see whether it should be re-instantiated
					if(synth.defName != synthDef,
						{
							var argList = buffers.getPairs++coreSynthArgs;
							synth.set(\gate, 0);
							synthDict.add(synthName -> Synth(synthDef, argList, synthGroup, 'addToTail'));
						},
						{
							// If it doesn't, just update it with the received buffers
							buffers.keysValuesDo({ |param, buff|
								synth.set(param, buff);
							});
					});
			});

			// Update synth immediately if in finite mode
			if(sessionMode == 'FiniteMode', {
				server.sync;
				synth.set(\t_manualActivateBufsTrig, 1);
			});

			this.debugPrint("loadSynthBuffers");
		};
	}

	setWindowDur{ |dur|
		windowDur = dur;
		timerSynth.set(\dur, windowDur);
		this.debugPrint("setWindowDur");
	}

	setLoop{ |loop|
		loop = loop;
		if(loop == 0,
			{timerSynth.set(\loopPoint, inf)},
			{timerSynth.set(\loopPoint, 1)}
		);
		this.debugPrint("setLoop");
	}

	setTimerSynth{ |dur, loop|
		windowDur = dur;
		loop = loop;
		timerSynth.set(
			\dur, windowDur,
			\loop, loop
		);
		this.debugPrint("setTimerSynths");
	}


	////////////////////////////////////////////////////////////////////////////////////
	// 4. Resetting

	resetTimer { |x|
		Routine.run {
			server.sync;

			// 0 mutes the timer, 1 unmutes it
			timerSynth.set(\mute, x);
			timerSynth.set(\t_manualTrig, 1);
			this.debugPrint("resetTimer");
		};
	}

	freeAllSynths {
		Routine.run {
			server.sync;

			synthGroup.free;
			synthGroup = Group.after(timerGroup);
			synthDict = Dictionary();

			inputBusDict.do{ |b| b.free };
			inputBusDict.clear;

			bufferDict.do{ |b| b.free };
			bufferDict.clear;

			this.debugPrint("freeAllSynths");
		}
	}

	resetServer {
		server.freeAll;
		this.init;
	}

	resetSession {
		sessionMode = 'FiniteMode';
		this.freeAllSynths;
		this.loadDefs;
		"TimeLines: session reset successfully".postln;
	}

	////////////////////////////////////////////////////////////////////////////////////
	// 5. Patching

	// Expects [src1, dst1, src2, dst2, ...]
	setPatches { |patches|
		Routine.run {
			server.sync;

			(patches.size / 2).do({ |i|
				var synthSrc = patches[2*i].asSymbol;
				var synthDst= patches[2*i + 1].asSymbol;

				this.patchFromTo(synthSrc, synthDst);
			});

			this.debugPrint("setPatches");
		};
	}

	// Expects symbols
	patchFromTo { |synth1, synth2|
		if(synth2 == 'mainOut', {
			synthDict[synth1].set(\out, mainOutputBus);
		}, {
			synthDict[synth1].set(\out, inputBusDict[synth2]);
		});
		this.debugPrint("patchFromTo");
	}

	////////////////// utils
	debugPrint { |funcName|
		if(b_debugging, {"DEBUG: % done, t = %".format(funcName.asString, Clock.seconds).postln});
	}

	invalidArgumentPrint { |funcName, argument|
		// this is what you have to resort to with dynamic languages....
		"ERROR: Function % received invalid argument % (class: %)"
		.format(funcName, argument, argument.class).postln;
	}

	*cmdPeriod {
		~timelinesCmdPeriod.value;
	}
}