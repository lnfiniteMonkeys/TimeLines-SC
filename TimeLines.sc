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
			~timelines.start;
			//ServerTree.add(this.start, server);
			"TimeLines: Initialization completed successfully".postln;
		};

		server.latency = 0.1;
	}

	*new { |numChannels = 2, server|
		^super.newCopyArgs(numChannels, server ? Server.default).init;
	}

	//Initializing variables, loading defs and preparing the server
	init {
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

		this.loadDefs;
		server.sync;
	}

	start {
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

		"TimeLines: TimeSynth started, listening on port 57120".postln;
	}

	//Load and execute all files ind the defs folder
	loadDefs {
		"defs/*.scd".resolveRelative.loadPaths
	}

	resetServer {
		this.freeAll;
		this.start;
		"TimeLines: server reset successfully".postln;
	}

	freeAll {
		//Iterate over the buffers and synths, free them and remove their dictionary entries
		bufferDict.keysValuesDo{|key, buff| buff.free; bufferDict.removeAt(key)};
		synthDict.keysValuesDo{|key, synth| synth.free; synthDict.removeAt(key)};
		timeSynth.free;
		reverbSynth.free;
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

		if(synth.isNil, {synthDict.add(synthName -> Synth(synthDef, target: synthGroup))}, {});

		bufferDict[buffName].free;
		bufferDict.add(buffName -> Buffer.read(server, filePath, action: {|b|
			synthDict[synthName].set(synthParam, b)}));
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


