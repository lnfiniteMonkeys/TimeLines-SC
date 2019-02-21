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
	//s.sampleRate = 48000;
	TimeLines.start(~numChannels, s, {"hello from the outside!".postln});
};

~timelinesCmdPeriod.value;
)