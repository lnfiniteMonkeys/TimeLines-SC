TimeLines {
	var <numChannels, <server;
	var <bufferDict, <synthDict;
	var <timeGroup, <synthGroup, <fxGroup, <reverbGroup;
	var timeSynth, reverbSynth, silencerSynth;
	var <windowDur = 1, <loop = 1;

	*start { |numChannels = 2, server|
		~timelines.free;
		//Use default server if one is not supplied
		server = server ? Server.default;

		server.waitForBoot {
			"Booting TimeLines...".postln;
			~timelines = TimeLines(numChannels, server);
			~timelines.startSynths;
			//ServerTree.add(TimeLines.start, server);
			"TimeLines: Initialization completed successfully\nListening on port 57120".postln;
		};

		server.latency = 0.1;
	}

	*new { |numChannels = 2, server|
		^super.newCopyArgs(numChannels, server ? Server.default).init;
	}

	//Initializing variables, loading defs and preparing the server
	init {
		this.initVariables;
		this.loadDefs;
		server.sync;
	}

	initVariables {
		~t = Bus.audio(server, 1);
		~silencerBus = Bus.audio(server, 1);
		~reverbOut = Bus.audio(server, 2);
		~reverbSilencedBus = Bus.audio(server, 2);
		~dryOut = Bus.audio(server, 2);

		bufferDict = Dictionary();
		synthDict = Dictionary();
		timeGroup = Group();
		synthGroup = Group.after(timeGroup);
		fxGroup = Group.after(synthGroup);
		reverbGroup = Group.after(fxGroup);
	}

	//Load and execute all files ind the defs folder
	loadDefs {
		"defs/*.scd".resolveRelative.loadPaths
	}

	// Starting the synths
	startSynths {
		timeSynth = Synth(\timer, [\dur, windowDur, \loopPoint, 1], timeGroup);
		reverbSynth = Synth.new(\reverb,
			[
				\amp, 1,
				\predelay, 0.1,
				\revtime, 1.8,
				\lpf, 4500,
				\mix, 0.35,
				\in, ~reverbSilencedBus,
				\out, 0,
			],
			reverbGroup
		);
		silencerSynth = Synth(\silencer, target: reverbGroup);
	}

		freeAll {
		// Free all busses
		~t.free;
		~silencerBus.free;
		~reverbOut.free;
		~reverbSilencedBus.free;
		~dryOut.free;

		// Free all groups and their synths
		timeGroup.free;
		synthGroup.free;
		fxGroup.free;
		reverbGroup.free;

		// Free all Buffers
		bufferDict.keysValuesDo{ |key, buff| buff.free; bufferDict.removeAt(key)};
		/*
		//Iterate over the buffers and synths, free them and remove their dictionary entries
		bufferDict.keysValuesDo{ |key, buff| buff.free; bufferDict.removeAt(key)};
		synthDict.keysValuesDo{ |key, synth| synth.free; synthDict.removeAt(key)};
		timeSynth.free;
		reverbSynth.free;
		*/
	}

	reset {
		this.freeAll;
		this.initVariables;
		this.loadDefs;
		this.startSynths;
		"TimeLines: server reset successfully".postln;
	}



	//Loads a buffer file, creates its synth if it's not already there
	//and assigns it to the appropriate argument
	loadBuffer { |path|
		var filePath = path.asString;
		var pathList = path.asString.split();
		var buffName = pathList[pathList.size - 1].split($.)[0];
		var info = buffName.split($_);

		var synthName = info[0].asSymbol;
		var synthDef = info[1];
		var synthParam = info[2].asSymbol;
		var synth = synthDict[synthName];
		var oldBuff = bufferDict[buffName];

		if(synth.isNil, {synthDict.add(synthName -> Synth(synthDef, target: synthGroup))}, {});
		bufferDict.add(buffName -> Buffer.read(server, filePath, action: {|b|
			synthDict[synthName].set(synthParam, b);
			oldBuff.free;
		}));
	}

	loadSynthBuffers { |paths|
		var numBuffs = paths.size;
		// Get synth info shared by all buffers
		var synthInfo = paths[0].asString.split(Platform.pathSeparator).reverse[0].split($_)[[0, 1]];
		// synthName e.g. "bob_fm"
		var synthName = format("%_%", synthInfo[0], synthInfo[1]).asSymbol;
		var synthDef = synthInfo[1].asSymbol;
		var synth = synthDict[synthName];

		var buffers = Dictionary();

		// First, loop over the received paths, load the buffers,
		// add them to the buffer dictionary and free the old ones
		paths.do({ |p|
			var path = p.asString;
			var buffName = path.split(Platform.pathSeparator).reverse[0].split($.)[0].asSymbol;
			var param = buffName.asString.split($_)[2].asSymbol;
			var prevBuff = bufferDict[buffName];

			buffName.postln;

			bufferDict.add(buffName ->
				Buffer.read(server, path, action:
					{ |b|
						prevBuff.free;
						buffers.add(param -> b);
				});
			);
		});

		// Using a routine for server.sync (?)
		Routine.run {
			server.sync;

			// Then, check if the synth already exists
			if(synth.isNil,
				{
					var argList = buffers.getPairs;
					"synth is nil".postln;
					// If it doesn't, instantiate it with the buffers as arguments and add it to the dictionary
					synthDict.add(synthName -> Synth(synthDef, argList, synthGroup))
				},
				{
					// If it does, check to see if its SynthDef matches the one received
					if(synth.defName != synthDef,
						{
							var argList = buffers.getPairs;
							"synthdefs dont match".postln;
							//If it doesn't, free it and re-instantiate it
							synth.free;
							synthDict.add(synthName -> Synth(synthDef, argList, synthGroup));
						},
						{
							"synthdefs match".postln;
							// If it does, just update it with the received buffers
							/*
							numBuffs.do({ |i|
							synth.set(params[i], buffers[i]);
							});
							*/
					});
			});
			"all done boss".postln;
		};
	}

	setWindow{ |dur|
		windowDur = dur;
		timeSynth.set(\dur, windowDur);
	}

	play {
		timeSynth.set(\t_manualTrig, 1);
	}

	setLoop{ |loop|
		loop = loop;
		if(loop == 0,
			{timeSynth.set(\loopPoint, inf)},
			{timeSynth.set(\loopPoint, 1)})
	}

	setTimeSynth{ |dur, loop|
		windowDur = dur;
		loop = loop;
		timeSynth.set(
		\dur, windowDur,
		\loop, loop);
	}
}


