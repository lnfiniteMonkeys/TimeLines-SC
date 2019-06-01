//TODO: test unpatched synths reset

(
~timelinesCmdPeriod  = {
	s.quit;

	~numChannels = 2;
	~panWidth = 2;
	~panOrientation = 1.5;

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
~x = {PinkNoise.ar(0.2)!2}.play;
)

~x.free
s.record("C:\\Users\\Carl\\Desktop\\monkeyStuff.wav");


(
s.stopRecording;
)

(
s.meter;
s.plotTree;

)


// REVERB
(
~timelines.reverbSynth.set(
	\predelay, 0.13,
	\revtime, 1.1,
	\lpf, 4500,
	\mix, 0.45
);
)

// COMPRESSOR
(
~timelines.compressorSynth.set(
	\thresh, 0.1,
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


~timelines.bufferDict['s1_fm_freq'].plot
~timelines.bufferDict['s1_fm_ratio'].plot