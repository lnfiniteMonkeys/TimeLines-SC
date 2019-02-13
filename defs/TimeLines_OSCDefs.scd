(

//~debugArgs( |arg| "arg: ".format(arg).postln; "arg class: %".format(arg.class).postln;)
OSCdef(\TimeLines_triggers, { |msg, time, addr, recvPort|
	if(msg[2] == 1, {~timelines.freeOldBuffers});
	if(msg[2] == 2, {~timelines.askNextBuffers});
	//if(msg[2] == 2, {"start of cycle".postln});
}, '/tr', s.addr).add;

OSCdef(\TimeLines_setSynthOrder, { |msg, time, addr, recvPort|
	~timelines.setSynthOrder(msg.drop(1));
	~timelines.debugPrint("OSC-setSynthOrder");
}, "/TimeLines/setSynthOrder").add;

OSCdef(\TimeLines_releaseBuffers, { |msg, time, addr, recvPort|
	~timelines.releaseBuffers;
	~timelines.debugPrint("OSC-releaseBuffers");
}, "/TimeLines/releaseBuffers").add;

OSCdef(\TimeLines_loadSynthBuffers, { |msg, time, addr, recvPort|
	~timelines.loadSynthBuffers(msg.drop(1));
	~timelines.debugPrint("OSC-loadSynthBuffers");
}, "/TimeLines/loadSynthBuffers").add;

OSCdef(\TimeLines_setPatches, { |msg, time, addr, recvPort|
	~timelines.setPatches(msg.drop(1));
	~timelines.debugPrint("OSC-setPatches");
}, "/TimeLines/setPatches").add;

OSCdef(\TimeLines_setWindowDur, { |msg, time, addr, recvPort|
	var dur = msg[1].asFloat;
	~timelines.setWindowDur(dur);
	~timelines.debugPrint("OSC-setWindowDur");
}, "/TimeLines/setWindowDur").add;

OSCdef(\TimeLines_setLoop, { |msg, time, addr, recvPort|
	var loop = msg[1].asFloat;
	~timelines.setLoop(loop);
	~timelines.debugPrint("OSC-setLoop");
}, "/TimeLines/setLoop").add;

OSCdef(\TimeLines_setSession, { |msg, time, addr, recvPort|
	~timelines.setSession(msg.drop(1));
	~timelines.debugPrint("OSC-setSession");
}, "/TimeLines/setSession").add;

OSCdef(\TimeLines_freeAllSynths, { |msg, time, addr, recvPort|
	~timelines.freeAllSynths;
	~timelines.debugPrint("OSC-freeAllSynth");
}, "/TimeLines/freeAllSynths").add;

OSCdef(\TimeLines_resetTimer, { |msg, time, addr, recvPort|
	("resetting timer with: " ++ msg[1].asInt).postln;
	~timelines.resetTimer(msg[1].asInt);
	~timelines.debugPrint("OSC-resetTimer");
}, "/TimeLines/resetTimer").add;

OSCdef(\TimeLines_setMute, { |msg, time, addr, recvPort|
	~timelines.setMute(msg[1].asInt);
	~timelines.debugPrint("OSC-setMute");
}, "/TimeLines/setMute").add;

OSCdef(\TimeLines_resetServer, {
	~timelines.resetServer;
	~timelines.debugPrint("OSC-resetServer");
}, "/TimeLines/resetServer").add;

"TimeLines: OSCDefs loaded".postln;
)