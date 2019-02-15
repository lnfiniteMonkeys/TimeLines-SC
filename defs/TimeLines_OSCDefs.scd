(

//~debugArgs( |arg| "arg: ".format(arg).postln; "arg class: %".format(arg.class).postln;)
OSCdef(\TimeLines_triggers, { |msg, time, addr, recvPort|
	if(msg[2] == 1, {~timelines.freeOldBuffers});
	if(msg[2] == 2, {~timelines.askNextBuffers});
	//if(msg[2] == 2, {"start of cycle".postln});
}, '/tr', s.addr).add;

OSCdef(\TimeLines_setSynthOrder, { |msg, time, addr, recvPort|
	~timelines.debugPrint("OSC-setSynthOrder");
	~timelines.setSynthOrder(msg.drop(1));
}, "/TimeLines/setSynthOrder").add;

OSCdef(\TimeLines_activateReceivedBuffers, { |msg, time, addr, recvPort|
	~timelines.debugPrint("OSC-activateReceivedBuffers");
	~timelines.activateReceivedBuffers;
}, "/TimeLines/activateReceivedBuffers").add;

OSCdef(\TimeLines_loadSynthBuffers, { |msg, time, addr, recvPort|
	~timelines.debugPrint("OSC-loadSynthBuffers");
	~timelines.loadSynthBuffers(msg.drop(1));
}, "/TimeLines/loadSynthBuffers").add;

OSCdef(\TimeLines_setPatches, { |msg, time, addr, recvPort|
	~timelines.debugPrint("OSC-setPatches");
	~timelines.setPatches(msg.drop(1));
}, "/TimeLines/setPatches").add;

OSCdef(\TimeLines_setWindowDur, { |msg, time, addr, recvPort|
	var dur = msg[1].asFloat;
	~timelines.debugPrint("OSC-setWindowDur");
	~timelines.setWindowDur(dur);
}, "/TimeLines/setWindowDur").add;

OSCdef(\TimeLines_setLoop, { |msg, time, addr, recvPort|
	var loop = msg[1].asFloat;
	~timelines.debugPrint("OSC-setLoop");
	~timelines.setLoop(loop);
}, "/TimeLines/setLoop").add;

OSCdef(\TimeLines_setSession, { |msg, time, addr, recvPort|
	"function called".postln;
	~timelines.debugPrint("OSC-setSession");
	~timelines.setSession(msg.drop(1));
}, "/TimeLines/setSession").add;

OSCdef(\TimeLines_freeAllSynths, { |msg, time, addr, recvPort|
	~timelines.debugPrint("OSC-freeAllSynth");
	~timelines.freeAllSynths;
}, "/TimeLines/freeAllSynths").add;

OSCdef(\TimeLines_resetTimer, { |msg, time, addr, recvPort|
	("resetting timer with: " ++ msg[1].asInt).postln;
	~timelines.debugPrint("OSC-resetTimer");
	~timelines.resetTimer(msg[1].asInt);
}, "/TimeLines/resetTimer").add;

OSCdef(\TimeLines_setMute, { |msg, time, addr, recvPort|
	~timelines.debugPrint("OSC-setMute");
	~timelines.setMute(msg[1].asInt);
}, "/TimeLines/setMute").add;

OSCdef(\TimeLines_resetSession, {
	~timelines.debugPrint("OSC-resetSession");
	~timelines.resetSession;
}, "/TimeLines/resetSession").add;

"TimeLines: OSCDefs loaded".postln;
)