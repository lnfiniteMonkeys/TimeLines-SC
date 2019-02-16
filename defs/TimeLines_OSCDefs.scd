(

//~debugArgs( |arg| "arg: ".format(arg).postln; "arg class: %".format(arg.class).postln;)
OSCdef(\TimeLines_triggers, { |msg, time, addr, recvPort|
	if(msg[2] == 1, {~timelines.freeOldBuffers});
	if(msg[2] == 2, {~timelines.askNextBuffers});

	if(msg[2] == 15, { ~improVisAddr.sendMsg("/vars/p1", msg[3]) });
	if(msg[2] == 16, { ~improVisAddr.sendMsg("/vars/p2", msg[3]) });
	if(msg[2] == 17, { ~improVisAddr.sendMsg("/vars/p3", msg[3]) });
	if(msg[2] == 18, { ~improVisAddr.sendMsg("/vars/p4", msg[3]) });

	//if(msg[2] == 2, {"start of cycle".postln});
}, '/tr', s.addr);

OSCdef(\TimeLines_setSynthOrder, { |msg, time, addr, recvPort|
	~timelines.debugPrint("OSC-setSynthOrder");
	~timelines.setSynthOrder(msg.drop(1));
}, "/TimeLines/setSynthOrder");

OSCdef(\TimeLines_activateReceivedBuffers, { |msg, time, addr, recvPort|
	~timelines.debugPrint("OSC-activateReceivedBuffers");
	~timelines.activateReceivedBuffers;
}, "/TimeLines/activateReceivedBuffers");

OSCdef(\TimeLines_loadSynthBuffers, { |msg, time, addr, recvPort|
	~timelines.debugPrint("OSC-loadSynthBuffers");
	~timelines.loadSynthBuffers(msg.drop(1));
}, "/TimeLines/loadSynthBuffers");

OSCdef(\TimeLines_setPatches, { |msg, time, addr, recvPort|
	~timelines.debugPrint("OSC-setPatches");
	~timelines.setPatches(msg.drop(1));
}, "/TimeLines/setPatches");

OSCdef(\TimeLines_setWindowDur, { |msg, time, addr, recvPort|
	var dur = msg[1].asFloat;
	~timelines.debugPrint("OSC-setWindowDur");
	~timelines.setWindowDur(dur);
}, "/TimeLines/setWindowDur");

OSCdef(\TimeLines_setLoop, { |msg, time, addr, recvPort|
	var loop = msg[1].asFloat;
	~timelines.debugPrint("OSC-setLoop");
	~timelines.setLoop(loop);
}, "/TimeLines/setLoop");

OSCdef(\TimeLines_setSession, { |msg, time, addr, recvPort|
	~timelines.debugPrint("OSC-setSession");
	~timelines.setSession(msg.drop(1));
}, "/TimeLines/setSession");

OSCdef(\TimeLines_freeAllSynths, { |msg, time, addr, recvPort|
	~timelines.debugPrint("OSC-freeAllSynth");
	~timelines.freeAllSynths;
}, "/TimeLines/freeAllSynths");

OSCdef(\TimeLines_resetTimer, { |msg, time, addr, recvPort|
	("resetting timer with: " ++ msg[1].asInt).postln;
	~timelines.debugPrint("OSC-resetTimer");
	~timelines.resetTimer(msg[1].asInt);
}, "/TimeLines/resetTimer");

OSCdef(\TimeLines_setMute, { |msg, time, addr, recvPort|
	~timelines.debugPrint("OSC-setMute");
	~timelines.setMute(msg[1].asInt);
}, "/TimeLines/setMute");

OSCdef(\TimeLines_resetSession, {
	~timelines.debugPrint("OSC-resetSession");
	~timelines.resetSession;
}, "/TimeLines/resetSession");

"TimeLines: OSCDefs loaded".postln;
)