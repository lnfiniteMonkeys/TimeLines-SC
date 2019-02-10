TimeLines {
	var <numChannels, <server;
	var <sessionType, <timerOn;
	var <bufferDict, <synthDict, <inputBusDict/*, <synthdefDict*/;
	var <buffersToFree;
	var <timerGroup, <synthGroup, <postSynthGroup;
	var <windowDur = 0.5, <loop = 1;
	var <ghcAddress;
	var <mainOutputBus, <silencerBus, <timerBus, <startTriggerBus;
	var <synthFadeInTime = 1, <synthFadeOutTime = 1;
	var timerSynth, silencerSynth;


	/*
	Contents:
	  * 1. Boot up
	  * 2. Initialization
	  * 3. Update loop
	  * 4. Resetting
	  * 5. Patching
	*/


	////////////////////////////////////////////////////////////////////////////////////
	// 1. Boot up

	*start { |numChannels = 2, server|
		~timelines.free;
		//Use default server if one is not supplied
		server = server ? Server.default;

		server.waitForBoot {
			"Booting TimeLines...".postln;
			~timelines = TimeLines(numChannels, server);
			~timelines.startSynths;
			//ServerTree.add(TimeLines.start, server);
			"TimeLines: Initialization completed successfully\nListening on port 57120\n".postln;
		};

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
	}

	initCoreVariables {
		mainOutputBus = 0;
		timerBus= Bus.audio(server, 1);
		silencerBus = Bus.audio(server, 1);
		startTriggerBus = Bus.audio(server, 1);

		buffersToFree = List.newClear();
		ghcAddress = NetAddr("127.0.0.1", 57121);

		bufferDict = Dictionary();
		synthDict = Dictionary();
		inputBusDict = Dictionary();
		//synthdefDict = Dictionary();

		timerGroup = Group();
		synthGroup = Group.after(timerGroup);
		postSynthGroup = Group.after(synthGroup);
	}

	//Load and execute all files ind the defs folder
	loadDefs {
		"defs/*.scd".resolveRelative.loadPaths
	}

	// Instantiate timer and silencer synths
	startSynths {
		timerSynth = Synth(\timer, [
			\dur, windowDur,
			\loopPoint, 1,
			\out, timerBus,
			\silencerBus, silencerBus,
			\triggerBus, startTriggerBus
		], timerGroup);
		// TODO: silencer reads main output and replaces it with result
		//silencerSynth = Synth(\silencer, target: postSynthGroup);
	}


	////////////////////////////////////////////////////////////////////////////////////
	// 3. Update loop


	// Not used at the moment
	// loadSession { |synthPathArrays|
	// 	synthPathArrays.do({ |synthPaths|
	// 		this.loadSynthBuffers(synthPaths);
	// 	});
	// }

	setSynthOrder { |order|
		"todo".postln;
	}

	// Remove synths that did not receive an update
	checkSynthNames { |names|
		// The names of synths that are running now but are not in the new list
		var removedSynths = synthDict.keys.difference(names);
		removedSynths.postln;
		removedSynths.do({ |name|
			this.freeSynth(name);
		});
	}

	freeSynth { |synthName|
		"freeing synth!".postln;
		synthDict[synthName].set(\gate, 0);
		synthDict.removeAt(synthName);
	}
	// releaseSynth { |synth|
	// 	synth.set(\gate, 0);
	// }

	freeOldBuffers{
		// Free all old buffers
		buffersToFree.do({ |b| b.free});
		buffersToFree.clear();
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
				\startTriggerBus, startTriggerBus
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

			// Read a buffer, log it in the bufferDict,
			// once loaded add to the buffers to update the synth with
			bufferDict.add(buffName ->
				Buffer.read(server, path, action:
					{ |b|
						buffers.add(param -> b);
				});
			);
		});

		// Using a routine for server.sync (?)
		Routine.run {
			server.sync;

			// Check if the synth already exists
			if(synth.isNil,
				{
					var argList = buffers.getPairs++coreSynthArgs;
					// each synth gets its own input bus
					inputBusDict.add(synthName -> Bus.audio(server, 1 /* numChannels */));
					argList = argList ++ [\input, inputBusDict[synthName]];
					// If it doesn't, instantiate it with the buffers as arguments and add it to the dictionary
					synthDict.add(synthName -> Synth(synthDef, argList, synthGroup, 'addToTail'));
				},
				{
					// If it does exist, check to see whether it should be re-instantiated
					if(synth.defName != synthDef,
						{
							var argList = buffers.getPairs++coreSynthArgs;
							synth.free;
							synthDict.add(synthName -> Synth(synthDef, argList, synthGroup));
						},
						{
							// If it doesn't, just update it with the received buffers
							buffers.keysValuesDo({ |param, buff|
								synth.set(param, buff);
							});
					});
			});
		};
	}

	setWindow{ |dur|
		windowDur = dur;
		timerSynth.set(\dur, windowDur);
	}

	play {
		timerSynth.set(\t_manualTrig, 1);
	}

	setLoop{ |loop|
		loop = loop;
		if(loop == 0,
			{timerSynth.set(\loopPoint, inf)},
			{timerSynth.set(\loopPoint, 1)})
	}

	setTimerSynth{ |dur, loop|
		windowDur = dur;
		loop = loop;
		timerSynth.set(
		\dur, windowDur,
		\loop, loop);
	}


	////////////////////////////////////////////////////////////////////////////////////
	// 4. Resetting

	resetTimer {
		timerSynth.set(\t_manualTrig, 1);
	}

	freeAllSynths {
		synthDict.do({ |key, synth|
			synth.set(\gate, 0);
			synthDict.removeAt(key);
		});

		bufferDict.keysValuesDo{ |key, buff| buff.free; bufferDict.removeAt(key)};
	}

	freeAll {
		// Free all busses
		timerBus.free;
		silencerBus.free;
		startTriggerBus.free;

		// Free all groups and their synths
		timerGroup.free;
		synthGroup.free;

		// Free all Buffers
		this.freeOldBuffers;
		bufferDict.keysValuesDo{ |key, buff| buff.free; bufferDict.removeAt(key)};
	}

	reset {
		this.freeAll;
		this.initCoreVariables;
		this.loadDefs;
		this.startSynths;
		"TimeLines: server reset successfully".postln;
	}

	////////////////////////////////////////////////////////////////////////////////////
	// 5. Patching

	// Expects [src1, dst1, src2, dst2, ...]
	setPatches { |patches|
		(patches.size / 2).do({ |i|
			var synthSrc = patches[2*i].asSymbol;
			var synthDst= patches[2*i + 1].asSymbol;

			this.patchFromTo(synthSrc, synthDst);
		});
	}


	// Expects symbols
	patchFromTo { |synth1, synth2|
		synthDict[synth1].set(\out, inputBusDict[synth2]);
	}

}