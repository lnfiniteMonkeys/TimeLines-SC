(


OSCdef(\TimeLines_triggers, {
	|msg, time|
	if(msg[2] == 0, {~timelines.freeOldBuffers});
	if(msg[2] == 1, {~timelines.ghcAddress.sendMsg("/incrementWindow", "")});
	//if(msg[2] == 2, {"start of cycle".postln});
	"function1"
}, '/tr', s.addr).add;

OSCdef(\TimeLines_synthNames, {
	|msg, time, addr, recvPort|
	~timelines.checkSynthNames(msg.drop(1));
	("checking synthNames: " ++ msg.drop(1)).postln;
}, "/TimeLines/synthNames").add;

OSCdef(\TimeLines_synthOrder, {
	|msg, time, addr, recvPort|
	~timelines.setSynthOrder(msg.drop(1));
	"function3"
}, "/TimeLines/synthOrder").add;

OSCdef(\TimeLines_loadSynthBuffers, {
	|msg, time, addr, recvPort|
	~timelines.loadSynthBuffers(msg.drop(1));
	("loadSynthBuffers: " ++ msg.drop(1)).postln;
}, "/TimeLines/loadSynthBuffers").add;

OSCdef(\TimeLines_patches, {
	|msg, time, addr, recvPort|
	~timelines.setPatches(msg.drop(1));
	("set Patches: " ++ msg.drop(1)).postln;
}, "/TimeLines/patches").add;


/*
OSCdef(\TimeLines_loadSynth, {
	|msg, time, addr, recvPort|
	"loadSynth".postln;
	~timelines.loadSynthBuffers(msg.drop(1), 'synth');
}, "/TimeLines/loadSynth").add;


OSCdef(\TimeLines_loadFx, {
	|msg, time, addr, recvPort|
	"loadFX".postln;
	~timelines.loadSynthBuffers(msg.drop(1), 'fx');
}, "/TimeLines/loadSynth").add;
*/

// freeAllSynths, resetTimer, setLoop

OSCdef(\TimeLines_play, {
	|msg, time, addr, recvPort|
	~timelines.play;
}, "/TimeLines/play").add;

OSCdef(\TimeLines_window, {
	|msg, time, addr, recvPort|
	var dur = msg[1].asFloat;
	~timelines.setWindow(dur);
}, "/TimeLines/setWindowDur").add;

OSCdef(\TimeLines_loop, {
	|msg, time, addr, recvPort|
	var loop = msg[1].asFloat;
	~timelines.setLoop(loop);
}, "/TimeLines/setLoop").add;

OSCdef(\TimeLines_freeAllSynths, {
	|msg, time, addr, recvPort|
	var loop = msg[1].asFloat;
	~timelines.freeAllSynths();
}, "/TimeLines/freeAllSynths").add;

OSCdef(\TimeLines_resetTimer, {
	~timelines.resetTimer;
}, "/TimeLines/resetTimer").add;

OSCdef(\TimeLines_reset, {
	~timelines.reset;
}, "/TimeLines/reset").add;

OSCdef(\TimeLines_patch, {
	|msg, time, addr, recvPort|
	//var output = msg[1].split($_)[0];
	// var input = msg[2];

	msg.postln;

}, "/TimeLines/patch").add;

"TimeLines: OSCDefs loaded".postln;
)