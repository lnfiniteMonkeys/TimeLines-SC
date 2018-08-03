(
OSCdef(\TimeLines_load, {
	|msg, time, addr, recvPort|
	~timelines.loadBuffer(msg[1]);
}, "/TimeLines/load").add;

OSCdef(\TimeLines_play, {
	|msg, time, addr, recvPort|
	~func.(msg[1]);
}, "/TimeLines/play").add;

OSCdef(\TimeLines_window, {
	|msg, time, addr, recvPort|
	var dur = msg[1].asFloat;
	var sr = 700;
	var numFrames = sr*dur;

	~timeSynth.set(
		\cycleDur, dur,
		\r, numFrames);
}, "/TimeLines/setWindow").add;

OSCdef(\TimeLines_reset, {
	|msg, time, addr, recvPort|
	~timelines.resetServer;
}, "/TimeLines/reset").add;
)