//TODO: test unpatched synths reset

(
~timelinesCmdPeriod  = {
	s.quit;

	~numChannels = 2;
	~panWidth = 2;
	~panOrientation = 1.5;

	OSCdef.freeAll;

	s.options.numBuffers = 2048;
	s.options.numOutputBusChannels = ~numChannels;
	s.options.memSize = 8192 * 10;
	s.options.numOutputBusChannels = 10;
	//s.sampleRate = 48000;
	TimeLines.start(~numChannels, s, {"hello from the outside!".postln});
};

~timelinesCmdPeriod.value;
)

(
s.meter;
s.plotTree;
)


// REVERB
(
~timelines.reverbSynth.set(
	\predelay, 0.2,
	\revtime, 2.8,
	\lpf, 1500,
	\mix, 0.65
);
)

// COMPRESSOR
(
~timelines.compressorSynth.set(
	\thresh, 0.7,
	\slopeBelow, 1.0,
	\slopeAbove, 1.0,
	\clampTime, 0.01,
	\relaxTime, 0.1
);
)

/*
1. Start SuperCollider
2. Start Emacs
3. Start a TimeLines GHCi session with one synth (?)
4. Run 'TimeLines.start' here
*/
''

/*
TODO:
- Automatically plug synths to main output if they haven't been plugged anywhere else
- Sort out channel numbers w/ busses
-
*/
