(
OSCdef(\TimeLines_load, {
	|msg, time, addr, recvPort|
	~timelines.loadBuffer(msg[1]);
}, "/TimeLines/load").add;

OSCdef(\TimeLines_play, {
	|msg, time, addr, recvPort|
	~timelines.play;
}, "/TimeLines/play").add;

OSCdef(\TimeLines_window, {
	|msg, time, addr, recvPort|
	var dur = msg[1].asFloat;
	~timelines.setWindow(dur);
}, "/TimeLines/setWindow").add;

OSCdef(\TimeLines_loop, {
	|msg, time, addr, recvPort|
	var loop = msg[1].asFloat;
	~timelines.setLoop(loop);
	"loop %".format(loop).postln;
}, "/TimeLines/setLoop").add;

OSCdef(\TimeLines_reset, {
	|msg, time, addr, recvPort|
	~timelines.resetServer;
}, "/TimeLines/reset").add;

"OSCDefs loaded".postln;
)