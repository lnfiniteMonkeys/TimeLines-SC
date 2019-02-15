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


	var amp_ = BufRd.kr(1, Latch.ar(\amp.ar(), startTrig), t * BufFrames.kr(\amp.ar())).clip(0, 1);
	var freq_ = BufRd.kr(1, Latch.ar(\freq.ar(), startTrig), t * BufFrames.kr(\freq.ar()));
	var pan_ = BufRd.kr(1, Latch.ar(\pan.ar(), startTrig), t * BufFrames.kr(\pan.ar())).clip(-1, 1);




	var sig = in; // go wild


	var env = Linen.kr(\gate.kr(1), ~fadeInTime, 1, ~fadeOutTime, 2);
	Out.ar(\out.kr(), env * PanAz.ar(~numChannels, sig, pan_, width: ~panWidth, orientation: ~panOrientation));
}).add;


*/

SynthDef(\RLPF, {
	var t = In.ar(\timerBus.kr());
	var startTrig = In.ar(\activateBufsTriggerBus.kr()) + \t_manualActivateBufsTrig.kr(0);
      var in = In.ar(\input.kr(), ~numChannels);

	var amp_ = BufRd.kr(1, Latch.ar(\amp.ar(), startTrig), t * BufFrames.kr(\amp.ar())).clip(0, 1);
	var freq_ = BufRd.kr(1, Latch.ar(\freq.ar(), startTrig), t * BufFrames.kr(\freq.ar()));
	var rq_ = BufRd.kr(1, Latch.ar(\rq.ar(), startTrig), t * BufFrames.kr(\rq.ar()));

	var pan_ = BufRd.kr(1, Latch.ar(\pan.ar(), startTrig), t * BufFrames.kr(\pan.ar())).clip(-1, 1);

	var sig = RLPF.ar(in, freq_, rq_) * amp_;

	var env = Linen.kr(\gate.kr(1), ~fadeInTime, 1, ~fadeOutTime, 2);
	Out.ar(\out.kr(), env * PanAz.ar(~numChannels, sig, pan_, width: ~panWidth, orientation: ~panOrientation));
}).add;

SynthDef(\moogLPF, {
	var t = In.ar(\timerBus.kr());
	var startTrig = In.ar(\activateBufsTriggerBus.kr()) + \t_manualActivateBufsTrig.kr(0);
      var in = In.ar(\input.kr(), ~numChannels);

	var amp_ = BufRd.kr(1, Latch.ar(\amp.ar(), startTrig), t * BufFrames.kr(\amp.ar())).clip(0, 1);
	var freq_ = BufRd.kr(1, Latch.ar(\freq.ar(), startTrig), t * BufFrames.kr(\freq.ar()));
	var gain_ = BufRd.kr(1, Latch.ar(\gain.ar(), startTrig), t * BufFrames.kr(\gain.ar())).clip(0.0001, 0.9999);

	var pan_ = BufRd.kr(1, Latch.ar(\pan.ar(), startTrig), t * BufFrames.kr(\pan.ar())).clip(-1, 1);

	var sig = MoogFF.ar(in, freq_, gain_) * amp_;

	var env = Linen.kr(\gate.kr(1), ~fadeInTime, 1, ~fadeOutTime, 2);
	Out.ar(\out.kr(), env * PanAz.ar(~numChannels, sig, pan_, width: ~panWidth, orientation: ~panOrientation));
}).add;


SynthDef(\fm, {
	var t = In.ar(\timerBus.kr());
	var startTrig = In.ar(\activateBufsTriggerBus.kr()) + \t_manualActivateBufsTrig.kr(0);

	var freq_ = BufRd.kr(1, Latch.ar(\freq.ar(), startTrig), t * BufFrames.kr(\freq.ar())).clip(20, 20000);
	var amp_ = BufRd.kr(1, Latch.ar(\amp.ar(), startTrig), t * BufFrames.kr(\amp.ar())).clip(0, 1);
	var pan_ = BufRd.kr(1, Latch.ar(\pan.ar(), startTrig), t * BufFrames.kr(\pan.ar())).clip(-1, 1);

	var ratio_ = BufRd.kr(1, Latch.ar(\ratio.ar(), startTrig), t * BufFrames.kr(\ratio.ar()));
	var index_ = BufRd.kr(1, Latch.ar(\index.ar(), startTrig), t * BufFrames.kr(\index.ar()));

	var env = Linen.kr(\gate.kr(1), ~fadeInTime, 1, ~fadeOutTime, 2);

	var modFreq = freq_*ratio_;
	var mod = SinOsc.ar(modFreq)*index_;
	var sig = SinOsc.ar(freq_ + mod) * amp_ * env;

	Out.ar(\out.kr(), Pan2.ar(sig, pan_));
}).add;

SynthDef(\delay, {
	var t = In.ar(\timerBus.kr());
	var startTrig = In.ar(\activateBufsTriggerBus.kr()) + \t_manualActivateBufsTrig.kr(0);

	var delayTime_ = BufRd.kr(1, Latch.ar(\delayTime.ar(), startTrig), t * BufFrames.kr(\delayTime.ar())).clip(0, ~maxDelayTime);
	var decayTime_= BufRd.kr(1, Latch.ar(\decayTime.ar(), startTrig), t * BufFrames.kr(\decayTime.ar()));
	var amp_ = BufRd.kr(1, Latch.ar(\amp.ar(), startTrig), t * BufFrames.kr(\amp.ar())).clip(0, 1);
	var pan_ = BufRd.kr(1, Latch.ar(\pan.ar(), startTrig), t * BufFrames.kr(\pan.ar())).clip(-1, 1);

	var env = Linen.kr(\gate.kr(1), ~fadeInTime, 1, ~fadeOutTime, 2);

	var in = In.ar(\input.kr(), ~numChannels);

	var sig = AllpassL.ar(in, ~maxDelayTime, delayTime_, decayTime_) * amp_;

	Out.ar(\out.kr(), Pan2.ar(sig, pan_));
}).add;



SynthDef(\inputTest, {
	var t = In.ar(\timerBus.kr());
	var startTrig = In.ar(\activateBufsTriggerBus.kr()) + \t_manualActivateBufsTrig.kr(0);

	var cutoff_ = BufRd.kr(1, Latch.ar(\cutoff.ar(), startTrig), t * BufFrames.kr(\cutoff.ar())).clip(20, 20000);
	var amp_ = BufRd.kr(1, Latch.ar(\amp.ar(), startTrig), t * BufFrames.kr(\amp.ar())).clip(0, 1);
	var pan_ = BufRd.kr(1, Latch.ar(\pan.ar(), startTrig), t * BufFrames.kr(\pan.ar())).clip(-1, 1);

	var env = Linen.kr(\gate.kr(1), ~fadeInTime, 1, ~fadeOutTime, 2);

	var sig = RLPF.ar(In.ar(\input.kr()), cutoff_, 1) * env * amp_;

	Out.ar(\out.kr(), Pan2.ar(sig, pan_));
}).add;

/*
SynthDef(\sawDFMdelay, {
	var sig = VarSaw.ar(freq_, 0, width_) + VarSaw.ar(freq_+dtune_, 0.5, width_);


*/

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


/*
//by Eli Fieldsteel
SynthDef(\reverb, {
	arg in, predelay=0.1, revtime=1.8,
	lpf=4500, mix=0.15, amp=1, out=0;

	var dry, wet, temp, sig;
	dry = In.ar(in,2);
	temp = In.ar(in,2);
	wet = 0;
	temp = DelayN.ar(temp, 0,2, predelay);
	16.do{
		temp = AllpassN.ar(temp, 0.05, {Rand(0.001,0.05)}!2, revtime);
		temp = LPF.ar(temp, lpf);
		wet = wet + temp;
	};
	sig = XFade2.ar(dry, wet, mix*2-1, amp);

	Out.ar(out, sig);
}).add;
*/


/*

SynthDef(\sine4, {
	|amp, amp1, freq1, amp2, freq2, amp3, freq3, amp4, freq4|

	var t  = In.ar(~t);
	var amp_ = BufRd.kr(1, amp, t * BufFrames.kr(amp));
	var amp1_ = BufRd.kr(1, amp1, t * BufFrames.kr(amp1));
	var freq1_ = BufRd.kr(1, freq1, t * BufFrames.kr(freq1)).lag2(~lagTime);
	var amp2_ = BufRd.kr(1, amp2, t * BufFrames.kr(amp2));
	var freq2_ = BufRd.kr(1, freq2, t * BufFrames.kr(freq2)).lag2(~lagTime);
	var amp3_ = BufRd.kr(1, amp3, t * BufFrames.kr(amp3));
	var freq3_ = BufRd.kr(1, freq3, t * BufFrames.kr(freq3)).lag2(~lagTime);
	var amp4_ = BufRd.kr(1, amp4, t * BufFrames.kr(amp4));
	var freq4_ = BufRd.kr(1, freq4, t * BufFrames.kr(freq4)).lag2(~lagTime);

	var fade = Env([0, 1], [~fadeTime]).kr(0);

	var sin1 = Pan2.ar(SinOsc.ar(freq1_) * amp1_, LFNoise2.kr(~noiseFreq)) * fade * fade;
	var sin2 = Pan2.ar(SinOsc.ar(freq2_) * amp2_, LFNoise2.kr(~noiseFreq)) * fade * fade;
	var sin3 = Pan2.ar(SinOsc.ar(freq3_) * amp3_, LFNoise2.kr(~noiseFreq)) * fade * fade;
	var sin4 = Pan2.ar(SinOsc.ar(freq4_) * amp4_, LFNoise2.kr(~noiseFreq)) * fade * fade;

	var sig = (sin1 + sin2 + sin3 + sin4)/4 * amp_ * fade * fade;
	Out.ar(~reverbOut, sig*fade);
}).add;

*/

"TimeLines: SynthDefs loaded".postln;
)