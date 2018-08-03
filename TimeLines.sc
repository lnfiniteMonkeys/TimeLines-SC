TimeLines {

	var <numChannels, <server;
	var <bufferDict, <synthDict;
	var <timeGroup, <synthGroup, <fxGroup;
	var timeSynth;

	*start { |numChannels = 2, server|
		~timelines.free;
		server = server ? Server.default;
		"Starting TimeLines".postln;

		server.waitForBoot {
			~timelines = TimeLines(numChannels, server);
			~timelines.start;
		};

		server.latency = 0.1;
	}

	*new { |numChannels = 2, server|
		^super.newCopyArgs(numChannels, server ? Server.default).init;
	}

	init {
		~t = Bus.audio(this.server, 1);
		~reverbBus = Bus.audio(this.server, 2);
		~out = 0;
		~fadeTime = 3;
		this.loadDefs;
		this.resetServer;
		timeSynth = Synth(\phasor, [\cycleDur, 5, \r, 5*700], timeGroup);
}
	start {
		"Listening on port 57120".postln;
		//this.loadSynthDefs;
	}

	loadDefs {
		"TimeLines_SynthDefs.scd".resolveRelative.load;
		"TimeLines_OSCDefs.scd".resolveRelative.load;
		"TimeLines: SynthDefs and OSCDefs loaded successfully".postln;
	}

	resetServer {
		bufferDict.do(_.free);
		synthDict.do(_.free);

		bufferDict = Dictionary();
		synthDict = Dictionary();
		timeGroup = Group();
		synthGroup = Group.after(timeGroup);
		fxGroup = Group.after(synthGroup);

		synthDict.add(\reverb -> Synth.new(
			\reverb,
			[
				\amp, 1,
				\predelay, 0.1,
				\revtime, 1.8,
				\lpf, 4500,
				\mix, 0.35,
				\in, ~reverbBus,
				\out, ~out,
			],
			fxGroup
		));

		"TimeLines: server reset successfully".postln;
	}

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
		bufferDict.add(buffName -> Buffer.read(server, filePath, action: {|b| synthDict[synthName].set(synthParam, b)}));
	}
}


