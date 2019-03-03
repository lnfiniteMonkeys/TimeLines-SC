(
~timelinesCmdPeriod  = {
	s.quit;

	~numChannels = 2;

	s.options.numBuffers = 2048;
	s.options.numOutputBusChannels = ~numChannels;
	s.options.memSize = 8192 * 10;
	//s.sampleRate = 48000;

	TimeLines.start(~numChannels, s);
};

~timelinesCmdPeriod.value;
)