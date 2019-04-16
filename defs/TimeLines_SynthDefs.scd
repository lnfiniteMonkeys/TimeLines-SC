(
~fadeOutTime = 1;
~fadeInTime = 1;
~maxDelayTime = 10;


/*
> SynthDef template

TODO: use .wrap


SynthDef(__, {
	var t = In.ar(\timerBus.kr());
	var startTrig = In.ar(\activateBufsTriggerBus.kr()) + \t_manualActivateBufsTrig.kr(0);
    var in = In.ar(\input.kr(), ~numChannels);

	var amp = BufRd.kr(1, Latch.ar(\amp.ar(), startTrig), t * BufFrames.kr(\amp.ar())).clip(0, 1);
	var freq = BufRd.kr(1, Latch.ar(\freq.ar(), startTrig), t * BufFrames.kr(\freq.ar()));
	var pan = BufRd.kr(1, Latch.ar(\pan.ar(), startTrig), t * BufFrames.kr(\pan.ar())).clip(-1, 1);

	var sig = in; // go wild

	var env = Linen.kr(\gate.kr(1), ~fadeInTime, 1, ~fadeOutTime, 2);
	Out.ar(\out.kr(), env * PanAz.ar(~numChannels, sig, pan, width: ~panWidth, orientation: ~panOrientation));
}).add;


*/


/*
SynthDef(\mixer4, {
	var t = In.ar(\timerBus.kr());
	var startTrig = In.ar(\activateBufsTriggerBus.kr()) + \t_manualActivateBufsTrig.kr(0);

    var in = In.ar(\input.kr(), ~numChannels);

	var amp = BufRd.kr(1, Latch.ar(\amp.ar(), startTrig), t * BufFrames.kr(\amp.ar())).clip(0, 1);
	var freq = BufRd.kr(1, Latch.ar(\freq.ar(), startTrig), t * BufFrames.kr(\freq.ar()));
	var pan = BufRd.kr(1, Latch.ar(\pan.ar(), startTrig), t * BufFrames.kr(\pan.ar())).clip(-1, 1);

	var sig = in;

	var env = Linen.kr(\gate.kr(1), ~fadeInTime, 1, ~fadeOutTime, 2);
	Out.ar(\out.kr(), env * PanAz.ar(~numChannels, sig, pan, width: ~panWidth, orientation: ~panOrientation));
}).add;

*/



SynthDef(\operator, {
	var t = In.ar(\timerBus.kr());
	var startTrig = In.ar(\activateBufsTriggerBus.kr()) + \t_manualActivateBufsTrig.kr(0);

	var amp = BufRd.kr(1, Latch.ar(\amp.ar(), startTrig), t * BufFrames.kr(\amp.ar())).clip(0, 1);
	var freq = BufRd.kr(1, Latch.ar(\freq.ar(), startTrig), t * BufFrames.kr(\freq.ar()));
	var amt = BufRd.kr(1, Latch.ar(\amt.ar(), startTrig), t * BufFrames.kr(\amt.ar()));

	var in = In.ar(\input.kr(), 1).linlin(-1, 1, amt.neg, amt);

	var sig = SinOsc.ar(freq + in) * amp;

	var env = Linen.kr(\gate.kr(1), ~fadeInTime, 1, ~fadeOutTime, 2);
	Out.ar(\out.kr(), env * sig);
}).add;






SynthDef(\val, {
	var t = In.ar(\timerBus.kr());
	var startTrig = In.ar(\activateBufsTriggerBus.kr()) + \t_manualActivateBufsTrig.kr(0);

	var val = BufRd.ar(1, Latch.ar(\val.ar(), startTrig), t * BufFrames.kr(\val.ar()));

	var env = Linen.kr(\gate.kr(1), ~fadeInTime, 1, ~fadeOutTime, 2);
	Out.ar(2, env * val);
}).add;




SynthDef(\testMultichannel, {
	var sig = PinkNoise.ar(0.2);

	Out.ar(\out.kr(),
		PanAz.ar(~numChannels, sig, \pan.kr(0),
			width: \width.kr(1),
			orientation: \orientation.kr(0.5))
	);
}).add;



~noiseFreq = 3;
~lagTime = 3;
SynthDef(\sine4, {
	var t = In.ar(\timerBus.kr());
	var startTrig = In.ar(\activateBufsTriggerBus.kr()) + \t_manualActivateBufsTrig.kr(0);
	var in = In.ar(\input.kr(), ~numChannels);

	var amp = BufRd.kr(1, Latch.ar(\amp.ar(), startTrig), t * BufFrames.kr(\amp.ar())).clip(0, 1);
	var amp1 = BufRd.kr(1, Latch.ar(\amp1.ar(), startTrig), t * BufFrames.kr(\amp1.ar())).clip(0, 1);
	var freq1 = BufRd.kr(1, Latch.ar(\freq1.ar(), startTrig), t * BufFrames.kr(\freq1.ar())).lag2(~lagTime);
	var amp2 = BufRd.kr(1, Latch.ar(\amp2.ar(), startTrig), t * BufFrames.kr(\amp2.ar())).clip(0, 1);
	var freq2 = BufRd.kr(1, Latch.ar(\freq2.ar(), startTrig), t * BufFrames.kr(\freq2.ar())).lag2(~lagTime);
	var amp3 = BufRd.kr(1, Latch.ar(\amp3.ar(), startTrig), t * BufFrames.kr(\amp3.ar())).clip(0, 1);
	var freq3 = BufRd.kr(1, Latch.ar(\freq3.ar(), startTrig), t * BufFrames.kr(\freq3.ar())).lag2(~lagTime);
	var amp4 = BufRd.kr(1, Latch.ar(\amp4.ar(), startTrig), t * BufFrames.kr(\amp4.ar())).clip(0, 1);
	var freq4 = BufRd.kr(1, Latch.ar(\freq4.ar(), startTrig), t * BufFrames.kr(\freq4.ar())).lag2(~lagTime);

	var sin1 = Pan2.ar(SinOsc.ar(freq1) * amp1, LFNoise2.kr(~noiseFreq));
	var sin2 = Pan2.ar(SinOsc.ar(freq2) * amp2, LFNoise2.kr(~noiseFreq));
	var sin3 = Pan2.ar(SinOsc.ar(freq3) * amp3, LFNoise2.kr(~noiseFreq));
	var sin4 = Pan2.ar(SinOsc.ar(freq4) * amp4, LFNoise2.kr(~noiseFreq));

	var sig = (sin1 + sin2 + sin3 + sin4)/4 * amp;

	var env = Linen.kr(\gate.kr(1), ~fadeInTime, 1, ~fadeOutTime, 2);
	Out.ar(\out.kr(), env * sig);
}).add;




SynthDef(\RLPF, {
	var t = In.ar(\timerBus.kr());
	var startTrig = In.ar(\activateBufsTriggerBus.kr()) + \t_manualActivateBufsTrig.kr(0);
	var in = In.ar(\input.kr(), ~numChannels);

	var amp = BufRd.kr(1, Latch.ar(\amp.ar(), startTrig), t * BufFrames.kr(\amp.ar())).clip(0, 1);
	var freq = BufRd.kr(1, Latch.ar(\freq.ar(), startTrig), t * BufFrames.kr(\freq.ar()));
	var rq = BufRd.kr(1, Latch.ar(\rq.ar(), startTrig), t * BufFrames.kr(\rq.ar()));

	var pan = BufRd.kr(1, Latch.ar(\pan.ar(), startTrig), t * BufFrames.kr(\pan.ar())).clip(-1, 1);

	var sig = RLPF.ar(in, freq, rq) * amp;

	var env = Linen.kr(\gate.kr(1), ~fadeInTime, 1, ~fadeOutTime, 2);
	Out.ar(\out.kr(), env * PanAz.ar(~numChannels, sig, pan, width: ~panWidth, orientation: ~panOrientation));
}).add;


SynthDef(\compressor, {
	var in = In.ar(\bus.kr(), ~numChannels);

	var sig = Compander.ar(in, in, \thresh.kr(0.5), \slopeBelow.kr(1), \slopeAbove.kr(1), \clampTime.kr(0.01), \relaxTime.kr(0.1));

	ReplaceOut.ar(\bus.kr(), sig);
}).add;



SynthDef(\DFM, {
	var t = In.ar(\timerBus.kr());
	var startTrig = In.ar(\activateBufsTriggerBus.kr()) + \t_manualActivateBufsTrig.kr(0);
	var in = In.ar(\input.kr(), ~numChannels);

	var amp = BufRd.kr(1, Latch.ar(\amp.ar(), startTrig), t * BufFrames.kr(\amp.ar())).clip(0, 1);
	var freq = BufRd.kr(1, Latch.ar(\freq.ar(), startTrig), t * BufFrames.kr(\freq.ar()));
	var rq = BufRd.kr(1, Latch.ar(\res.ar(), startTrig), t * BufFrames.kr(\res.ar()));
	var gain = BufRd.kr(1, Latch.ar(\gain.ar(), startTrig), t * BufFrames.kr(\gain.ar()));
	var pan = BufRd.kr(1, Latch.ar(\pan.ar(), startTrig), t * BufFrames.kr(\pan.ar())).clip(-1, 1);

	var sig = DFM1.ar(in, freq, rq, gain) * amp;

	var env = Linen.kr(\gate.kr(1), ~fadeInTime, 1, ~fadeOutTime, 2);
	Out.ar(\out.kr(), env * PanAz.ar(~numChannels, sig, pan, width: ~panWidth, orientation: ~panOrientation));
}).add;


SynthDef(\moogLPF, {
	var t = In.ar(\timerBus.kr());
	var startTrig = In.ar(\activateBufsTriggerBus.kr()) + \t_manualActivateBufsTrig.kr(0);
	var in = In.ar(\input.kr(), ~numChannels);

	var amp = BufRd.kr(1, Latch.ar(\amp.ar(), startTrig), t * BufFrames.kr(\amp.ar())).clip(0, 1);
	var freq = BufRd.kr(1, Latch.ar(\freq.ar(), startTrig), t * BufFrames.kr(\freq.ar()));
	var gain = BufRd.kr(1, Latch.ar(\gain.ar(), startTrig), t * BufFrames.kr(\gain.ar())).clip(0.0001, 0.9999);

	var pan = BufRd.kr(1, Latch.ar(\pan.ar(), startTrig), t * BufFrames.kr(\pan.ar())).clip(-1, 1);

	var sig = MoogFF.ar(in, freq, gain) * amp;

	var env = Linen.kr(\gate.kr(1), ~fadeInTime, 1, ~fadeOutTime, 2);
	Out.ar(\out.kr(), env * PanAz.ar(~numChannels, sig, pan, width: ~panWidth, orientation: ~panOrientation));
}).add;



SynthDef(\fm, {
	var t = In.ar(\timerBus.kr());
	var startTrig = In.ar(\activateBufsTriggerBus.kr()) + \t_manualActivateBufsTrig.kr(0);

	var freq = BufRd.kr(1, Latch.ar(\freq.ar(), startTrig), t * BufFrames.kr(\freq.ar())).clip(20, 20000);
	var amp = BufRd.kr(1, Latch.ar(\amp.ar(), startTrig), t * BufFrames.kr(\amp.ar())).clip(0, 1);
	var pan = BufRd.kr(1, Latch.ar(\pan.ar(), startTrig), t * BufFrames.kr(\pan.ar())).clip(-1, 1);
	var ratio = BufRd.kr(1, Latch.ar(\ratio.ar(), startTrig), t * BufFrames.kr(\ratio.ar()));
	var index = BufRd.kr(1, Latch.ar(	\index.ar(), startTrig), t * BufFrames.kr(\index.ar()));

	var modFreq = freq*ratio;
	var mod = SinOsc.ar(modFreq)*index;
	var sig = SinOsc.ar(freq + mod) * amp;

	var env = Linen.kr(\gate.kr(1), ~fadeInTime, 1, ~fadeOutTime, 2);
	Out.ar(\out.kr(), env * PanAz.ar(~numChannels, sig, pan, width: ~panWidth, orientation: ~panOrientation));
}).add;


SynthDef(\vis, {
	var t = In.ar(\timerBus.kr());
	var startTrig = In.ar(\activateBufsTriggerBus.kr()) + \t_manualActivateBufsTrig.kr(0);

	var p1 = BufRd.kr(1, Latch.ar(\p1.ar(), startTrig), t * BufFrames.kr(\p1.ar()));
	var p2 = BufRd.kr(1, Latch.ar(\p2.ar(), startTrig), t * BufFrames.kr(\p2.ar()));
	var p3 = BufRd.kr(1, Latch.ar(\p3.ar(), startTrig), t * BufFrames.kr(\p3.ar()));
	var p4 = BufRd.kr(1, Latch.ar(\p4.ar(), startTrig), t * BufFrames.kr(\p4.ar()));

	var trig = Impulse.kr(30);

	SendTrig.kr(trig, 15, p1);
	SendTrig.kr(trig, 16, p2);
	SendTrig.kr(trig, 17, p3);
	SendTrig.kr(trig, 18, p4);
}).add;



SynthDef(\improVis, {
	var t = In.ar(\timerBus.kr());
	var startTrig = In.ar(\activateBufsTriggerBus.kr()) + \t_manualActivateBufsTrig.kr(0);

	var p1 = BufRd.kr(1, Latch.ar(\p1.ar(), startTrig), t * BufFrames.kr(\p1.ar()));
	var p2 = BufRd.kr(1, Latch.ar(\p2.ar(), startTrig), t * BufFrames.kr(\p2.ar()));
	var p3 = BufRd.kr(1, Latch.ar(\p3.ar(), startTrig), t * BufFrames.kr(\p3.ar()));
	var p4 = BufRd.kr(1, Latch.ar(\p4.ar(), startTrig), t * BufFrames.kr(\p4.ar()));

	var trig = Impulse.kr(30);

	SendTrig.kr(trig, 15, p1);
	SendTrig.kr(trig, 16, p2);
	SendTrig.kr(trig, 17, p3);
	SendTrig.kr(trig, 18, p4);
}).add;


SynthDef(\saw, {
	var t = In.ar(\timerBus.kr());
	var startTrig = In.ar(\activateBufsTriggerBus.kr()) + \t_manualActivateBufsTrig.kr(0);

	var freq = BufRd.kr(1, Latch.ar(\freq.ar(), startTrig), t * BufFrames.kr(\freq.ar())).clip(20, 20000);
	var amp = BufRd.kr(1, Latch.ar(\amp.ar(), startTrig), t * BufFrames.kr(\amp.ar())).clip(0, 1);
	var pan = BufRd.kr(1, Latch.ar(\pan.ar(), startTrig), t * BufFrames.kr(\pan.ar())).clip(-1, 1);
	var width = BufRd.kr(1, Latch.ar(\width.ar(), startTrig), t * BufFrames.kr(\width.ar()));

	var sig = VarSaw.ar(freq, width: width) * amp;

	var env = Linen.kr(\gate.kr(1), ~fadeInTime, 1, ~fadeOutTime, 2);
	Out.ar(\out.kr(), env * Pan2.ar(sig, pan));
}).add;


SynthDef(\saw4, {
	var t = In.ar(\timerBus.kr());
	var startTrig = In.ar(\activateBufsTriggerBus.kr()) + \t_manualActivateBufsTrig.kr(0);

	var amp = BufRd.kr(1, Latch.ar(\amp.ar(), startTrig), t * BufFrames.kr(\amp.ar())).clip(0, 1);
	var freq1 = BufRd.kr(1, Latch.ar(\freq1.ar(), startTrig), t * BufFrames.kr(\freq1.ar()));
	var freq2 = BufRd.kr(1, Latch.ar(\freq2.ar(), startTrig), t * BufFrames.kr(\freq2.ar()));
	var freq3 = BufRd.kr(1, Latch.ar(\freq3.ar(), startTrig), t * BufFrames.kr(\freq3.ar()));
	var freq4 = BufRd.kr(1, Latch.ar(\freq4.ar(), startTrig), t * BufFrames.kr(\freq4.ar()));

	var pan = BufRd.kr(1, Latch.ar(\pan.ar(), startTrig), t * BufFrames.kr(\pan.ar())).clip(-1, 1);
	var width = BufRd.kr(1, Latch.ar(\width.ar(), startTrig), t * BufFrames.kr(\width.ar()));

	var sig =
	(  VarSaw.ar(freq1, width: width)
	+ VarSaw.ar(freq2, width: width)
	+ VarSaw.ar(freq3, width: width)
	+ VarSaw.ar(freq4, width: width) ) * amp * (1/4);


	var env = Linen.kr(\gate.kr(1), ~fadeInTime, 1, ~fadeOutTime, 2);
	Out.ar(\out.kr(), env * Pan2.ar(sig, pan));
}).add;


SynthDef(\noiseDFM, {
	var t = In.ar(\timerBus.kr());
	var startTrig = In.ar(\activateBufsTriggerBus.kr()) + \t_manualActivateBufsTrig.kr(0);

	var amp = BufRd.kr(1, Latch.ar(\amp.ar(), startTrig), t * BufFrames.kr(\amp.ar())).clip(0, 1);
	var pan = BufRd.kr(1, Latch.ar(\pan.ar(), startTrig), t * BufFrames.kr(\pan.ar())).clip(-1, 1);

	var freq = BufRd.kr(1, Latch.ar(\freq.ar(), startTrig), t * BufFrames.kr(\freq.ar()));
	var res = BufRd.kr(1, Latch.ar(\res.ar(), startTrig), t * BufFrames.kr(\res.ar()));
	var gain = BufRd.kr(1, Latch.ar(\gain.ar(), startTrig), t * BufFrames.kr(\gain.ar()));


	var sig = DFM1.ar(WhiteNoise.ar(), freq, res, gain) * amp;

	var env = Linen.kr(\gate.kr(1), ~fadeInTime, 1, ~fadeOutTime, 2);
	Out.ar(\out.kr(), env * Pan2.ar(sig, pan));
}).add;



SynthDef(\noiseRLPF, {
	var t = In.ar(\timerBus.kr());
	var startTrig = In.ar(\activateBufsTriggerBus.kr()) + \t_manualActivateBufsTrig.kr(0);

	var amp = BufRd.kr(1, Latch.ar(\amp.ar(), startTrig), t * BufFrames.kr(\amp.ar())).clip(0, 1);
	var pan = BufRd.kr(1, Latch.ar(\pan.ar(), startTrig), t * BufFrames.kr(\pan.ar())).clip(-1, 1);

	var freq = BufRd.kr(1, Latch.ar(\freq.ar(), startTrig), t * BufFrames.kr(\freq.ar()));
	var rq = BufRd.kr(1, Latch.ar(\rq.ar(), startTrig), t * BufFrames.kr(\rq.ar()));


	var sig = RLPF.ar(WhiteNoise.ar(), freq, rq) * amp;

	var env = Linen.kr(\gate.kr(1), ~fadeInTime, 1, ~fadeOutTime, 2);
	Out.ar(\out.kr(), env * Pan2.ar(sig, pan));
}).add;


SynthDef(\noise, {
	var t = In.ar(\timerBus.kr());
	var startTrig = In.ar(\activateBufsTriggerBus.kr()) + \t_manualActivateBufsTrig.kr(0);

	var amp = BufRd.kr(1, Latch.ar(\amp.ar(), startTrig), t * BufFrames.kr(\amp.ar())).clip(0, 1);
	var pan = BufRd.kr(1, Latch.ar(\pan.ar(), startTrig), t * BufFrames.kr(\pan.ar())).clip(-1, 1);

	var sig = WhiteNoise.ar() * amp;

	var env = Linen.kr(\gate.kr(1), ~fadeInTime, 1, ~fadeOutTime, 2);
	Out.ar(\out.kr(), env * Pan2.ar(sig, pan));
}).add;


SynthDef(\delay, {
	var t = In.ar(\timerBus.kr());
	var startTrig = In.ar(\activateBufsTriggerBus.kr()) + \t_manualActivateBufsTrig.kr(0);
	var in = In.ar(\input.kr(), ~numChannels);

	var delayTime_ = BufRd.kr(1, Latch.ar(\delayTime.ar(), startTrig), t * BufFrames.kr(\delayTime.ar())).clip(0, ~maxDelayTime);
	var decayTime_= BufRd.kr(1, Latch.ar(\decayTime.ar(), startTrig), t * BufFrames.kr(\decayTime.ar()));
	var amp = BufRd.kr(1, Latch.ar(\amp.ar(), startTrig), t * BufFrames.kr(\amp.ar())).clip(0, 1);
	var pan = BufRd.kr(1, Latch.ar(\pan.ar(), startTrig), t * BufFrames.kr(\pan.ar())).clip(-1, 1);

	var sig = AllpassL.ar(in, ~maxDelayTime, delayTime_, decayTime_) * amp;

	var env = Linen.kr(\gate.kr(1), ~fadeInTime, 1, ~fadeOutTime, 2);
	Out.ar(\out.kr(), env * Pan2.ar(sig, pan));
}).add;


SynthDef(\timer, {
	var mute = (1 - \mute.kr(0)).clip(0, 1);
	var dur = 1 / (\dur.kr(1) * SampleRate.ir());

	// Resetable looping phasor
	var sig = Phasor.ar(
		\t_manualTrig.kr(0),
		dur,
		\startPoint.kr(0),
		//set loopPoint to 1 for looping, inf for no looping
		\loopPoint.kr(1),
		\startPoint.kr(0)
	);

	/*
	When the new cycle starts and the new buffers
	(which have already been received) are activated,
	then release the previous buffers and ask for the next batch
	*/

	var activateBufsTrigger = Changed.ar(sig, 0.01) * mute + \t_manualActivateBufsTrig.kr(0);
	var trigFreeOld = TDelay.ar(activateBufsTrigger, dur*0.9) * mute;
	var trigAskNext = TDelay.ar(activateBufsTrigger, 0.01) * mute;

	// Muting timer signal after the `Changed` UGen
	sig = sig * mute;

	// Signals the looping back of the phasor
	SendTrig.ar(activateBufsTrigger, 0);
	// Trigger for releasing old buffers
	SendTrig.ar(trigFreeOld, 1, sig);
	// Trigger for asking for next batch of buffers
	SendTrig.ar(trigAskNext, 2, sig);

	Out.ar(\activateBufsTriggerBus.kr(), activateBufsTrigger);
	Out.kr(\silencerBus.kr(), sig);
	Out.ar(\out.kr(), sig.clip(0, 1));
}).add;


SynthDef(\silencer, {
	var mute = (1 - \mute.kr(0)).clip(0, 1);
	var phasor = In.kr(\timerBus.kr());

	var switch = Lag2.kr(phasor < 1);
	var signal = In.ar(\bus.kr(), ~numChannels) * switch * mute;

	ReplaceOut.ar(\bus.kr(), signal);
}).add;


SynthDef(\limiter, {
	var signal = In.ar(\bus.kr(), ~numChannels);
	signal = Limiter.ar(signal, 0.95, 0.01);

	ReplaceOut.ar(\bus.kr(), signal);
}).add;


//by Eli Fieldsteel
SynthDef(\reverb, {
	arg predelay=0.1, revtime=1.8,
	lpf=4500, mix=0.15, amp=1;

	var dry, wet, temp, sig;

	dry = In.ar(\bus.kr(), ~numChannels);
	temp = In.ar(\bus.kr(), ~numChannels);
	wet = 0;
	temp = DelayN.ar(temp, 0,2, predelay);
	16.do{
		temp = AllpassN.ar(temp, 0.05, {Rand(0.001,0.05)}!2, revtime);
		temp = LPF.ar(temp, lpf);
		wet = wet + temp;
	};

	sig = XFade2.ar(dry, wet, mix*2-1, amp);

	ReplaceOut.ar(\bus.kr(), sig);
}).add;


/*

SynthDef(\sine4, {
	|amp, amp1, freq1, amp2, freq2, amp3, freq3, amp4, freq4|

	var t  = In.ar(~t);
	var amp = BufRd.kr(1, amp, t * BufFrames.kr(amp));
	var amp1 = BufRd.kr(1, amp1, t * BufFrames.kr(amp1));
	var freq1 = BufRd.kr(1, freq1, t * BufFrames.kr(freq1)).lag2(~lagTime);
	var amp2 = BufRd.kr(1, amp2, t * BufFrames.kr(amp2));
	var freq2 = BufRd.kr(1, freq2, t * BufFrames.kr(freq2)).lag2(~lagTime);
	var amp3 = BufRd.kr(1, amp3, t * BufFrames.kr(amp3));
	var freq3 = BufRd.kr(1, freq3, t * BufFrames.kr(freq3)).lag2(~lagTime);
	var amp4 = BufRd.kr(1, amp4, t * BufFrames.kr(amp4));
	var freq4 = BufRd.kr(1, freq4, t * BufFrames.kr(freq4)).lag2(~lagTime);

	var fade = Env([0, 1], [~fadeTime]).kr(0);

	var sin1 = Pan2.ar(SinOsc.ar(freq1) * amp1, LFNoise2.kr(~noiseFreq)) * fade * fade;
	var sin2 = Pan2.ar(SinOsc.ar(freq2) * amp2, LFNoise2.kr(~noiseFreq)) * fade * fade;
	var sin3 = Pan2.ar(SinOsc.ar(freq3) * amp3, LFNoise2.kr(~noiseFreq)) * fade * fade;
	var sin4 = Pan2.ar(SinOsc.ar(freq4) * amp4, LFNoise2.kr(~noiseFreq)) * fade * fade;

	var sig = (sin1 + sin2 + sin3 + sin4)/4 * amp * fade * fade;
	Out.ar(~reverbOut, sig*fade);
}).add;

*/

"TimeLines: SynthDefs loaded".postln;
)