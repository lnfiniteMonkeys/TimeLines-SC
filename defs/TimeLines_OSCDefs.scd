(

OSCdef(\TimeLines_triggers, { |msg, time, addr, recvPort|
	if(msg[2] == 0, {~timelines.freeOldBuffers});
	if(msg[2] == 1, {~timelines.ghcAddress.sendMsg("/incrementWindow", "")});
	//if(msg[2] == 2, {"start of cycle".postln});
}, '/tr', s.addr).add;

OSCdef(\TimeLines_currentSynths, { |msg, time, addr, recvPort|
	~timelines.checkSynthNames(msg.drop(1));
}, "/TimeLines/currentSynths").add;

OSCdef(\TimeLines_synthOrder, { |msg, time, addr, recvPort|
	~timelines.setSynthOrder(msg.drop(1));
}, "/TimeLines/synthOrder").add;

OSCdef(\TimeLines_loadSynthBuffers, { |msg, time, addr, recvPort|
	~timelines.loadSynthBuffers(msg.drop(1));
}, "/TimeLines/loadSynthBuffers").add;

OSCdef(\TimeLines_patches, { |msg, time, addr, recvPort|
	~timelines.setPatches(msg.drop(1));
}, "/TimeLines/patches").add;

OSCdef(\TimeLines_windowDur, { |msg, time, addr, recvPort|
	var dur = msg[1].asFloat;
	~timelines.setWindow(dur);
}, "/TimeLines/setWindowDur").add;

OSCdef(\TimeLines_loop, { |msg, time, addr, recvPort|
	var loop = msg[1].asFloat;
	~timelines.setLoop(loop);
}, "/TimeLines/setLoop").add;

OSCdef(\TimeLines_sessionMode, { |msg, time, addr, recvPort|
	~timelines.setSessionMode(msg[1].asSymbol);
}, "/TimeLines/setSessionMode").add;

OSCdef(\TimeLines_freeAllSynths, { |msg, time, addr, recvPort|
	~timelines.freeAllSynths();
}, "/TimeLines/freeAllSynths").add;

OSCdef(\TimeLines_resetTimer, { |msg, time, addr, recvPort|
	("resetting timer with: " ++ msg[1].asInt).postln;
	~timelines.resetTimer(msg[1].asInt);
}, "/TimeLines/resetTimer").add;

OSCdef(\TimeLines_setTimerActive, { |msg, time, addr, recvPort|
	~timelines.setTimerActive(msg[1].asInt);
}, "/TimeLines/setTimerActive").add;

OSCdef(\TimeLines_resetServer, {
	~timelines.resetServer;
}, "/TimeLines/resetServer").add;

"TimeLines: OSCDefs loaded".postln;
)