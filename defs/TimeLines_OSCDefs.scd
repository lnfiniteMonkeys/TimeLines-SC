(
OSCdef(\TimeLines_triggers, {
	|msg, time|
	msg.postln;
	if(msg[2] == 0, {
		//~timelines.loadNextBuffers;
	});

	if(msg[2] == 1, {
		//~timelines.askNewBuffers;
	});
}, '/tr', s.addr).add;

OSCdef(\TimeLines_load, {
	|msg, time, addr, recvPort|
	"loading buffers".postln;
	~timelines.loadSynthBuffers(msg.drop(1));
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
}, "/TimeLines/setLoop").add;

OSCdef(\TimeLines_reset, {
	|msg, time, addr, recvPort|
	~timelines.reset;
}, "/TimeLines/reset").add;

OSCdef(\TimeLines_plug, {
	|msg, time, addr, recvPort|
	var output = msg[1].split($_)[0];
	var input = msg[2];

	msg.postln;

}, "/TimeLines/plug").add;

"TimeLines: OSCDefs loaded".postln;
)