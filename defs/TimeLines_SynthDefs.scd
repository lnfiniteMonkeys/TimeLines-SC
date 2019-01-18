
/*
(
// the basic wrapper
~makeEffect = { |name, func, lags, numChannels = 2|
    SynthDef(name,
		{ |inBus, outBus = ~reverbOut, gate = 1, wet = 1|
			var in, out, t, env;
			in = In.ar(inputBus, numChannels);
			env = Linen.kr(gate, 2, 1, 2, 2); // fade in the effect

			// call the wrapped function. The in and env arguments are passed to the function
			// as the first two arguments (prependArgs).
			// Any other arguments of the wrapped function will be Controls.
			out = SynthDef.wrap(func, lags, [in, t]) * env;

			Out.ar(outBus, XFade2.ar(in, out, wet.range(-1, 1)));
	}).add;
};

~makeSynth = { |name, func|
	SynthDef(name,
		{ |inBus, outBus = 0, gate = 1, pan, amp|
			var sig, t, env, pan_, amp_;

			t = In.ar(~t);
			pan_ = BufRd.kr(1, pan, t * BufFrames.kr(pan));
			amp_ = BufRd.kr(1, amp, t * BufFrames.kr(amp));
			env = Linen.kr(gate, 2, 1, 2, 2);

			sig = SynthDef.wrap(func, prependArgs: [t]) * env * amp;

			Out.ar(outBus, Pan2.ar(sig, pan_));
	}).add;
};

)

(
~makeSynth.(\sinewave,
	{ |t, freq|
		SinOsc.ar(freq);
});
)


// now make a wah
(
~makeEffect.value(\wah, {|in, env, rate = 0.7, ffreq = 1200, depth = 0.8, rq = 0.1|
    // in and env come from the wrapper. The rest are controls
     var lfo;
    lfo = LFNoise1.kr(rate, depth * ffreq, ffreq);
    RLPF.ar(in, lfo, rq, 10).distort * 0.15; },
    [0.1, 0.1, 0.1, 0.1],  // lags for rate ffreq, depth and rq
    2    // numChannels
);
)

*/



(
~fadeTime = 3;
~fadeOutTime = 1;
~fadeInTime = 1;
~maxDelayTime = 10;

SynthDef(\noiseLPFdelay, {
	var t = In.ar(~t);
	var trig = Changed.ar(t, 0.1);

	var cutoff_ = BufRd.kr(1, Latch.ar(\cutoff.ar(), trig), t * BufFrames.kr(\cutoff.ar())).clip(20, 20000);
	var resonance_ = BufRd.kr(1, Latch.ar(\resonance.ar(), trig), t * BufFrames.kr(\resonance.ar())).clip(0.01, 5);
	var amp_ = BufRd.kr(1, Latch.ar(\amp.ar(), trig), t * BufFrames.kr(\amp.ar())).clip(0, 1);
	var pan_ = BufRd.kr(1, Latch.ar(\pan.ar(), trig), t * BufFrames.kr(\pan.ar())).clip(-1, 1);
	var delayTime_ = BufRd.kr(1, Latch.ar(\delayTime.ar(), trig), t * BufFrames.kr(\delayTime.ar()));
	var decayTime_ = BufRd.kr(1, Latch.ar(\decayTime.ar(), trig), t * BufFrames.kr(\decayTime.ar()));

	var env = Linen.kr(\gate.kr(1), ~fadeInTime, 1, ~fadeOutTime, 2);

	var sig = WhiteNoise.ar() * amp_ * env;

	sig = RLPF.ar(sig, cutoff_, resonance_);
	sig = AllpassC.ar(sig, ~maxDelayTime, delayTime_, decayTime_);

	Out.ar(~reverbOut, Pan2.ar(sig, pan_));
}).add;


SynthDef(\fmDelay, {
	var t = In.ar(~t);
	var trig = Changed.ar(t, 0.1);

	var freq_ = BufRd.kr(1, Latch.ar(\freq.ar(), trig), t * BufFrames.kr(\freq.ar())).clip(20, 20000);
	var amp_ = BufRd.kr(1, Latch.ar(\amp.ar(), trig), t * BufFrames.kr(\amp.ar())).clip(0, 1);
	var pan_ = BufRd.kr(1, Latch.ar(\pan.ar(), trig), t * BufFrames.kr(\pan.ar())).clip(-1, 1);
	var ratio_ = BufRd.kr(1, Latch.ar(\ratio.ar(), trig), t * BufFrames.kr(\ratio.ar()));
	var index_ = BufRd.kr(1, Latch.ar(\index.ar(), trig), t * BufFrames.kr(\index.ar()));
	var delayTime_ = BufRd.kr(1, Latch.ar(\delayTime.ar(), trig), t * BufFrames.kr(\delayTime.ar()));
	var decayTime_ = BufRd.kr(1, Latch.ar(\decayTime.ar(), trig), t * BufFrames.kr(\decayTime.ar()));

	var env = Linen.kr(\gate.kr(1), ~fadeInTime, 1, ~fadeOutTime, 2);

	var modFreq = freq_*ratio_;
	var mod = SinOsc.ar(modFreq)*index_;
	var sig = SinOsc.ar(freq_ + mod) * amp_ * env;

	sig = AllpassC.ar(sig, ~maxDelayTime, delayTime_, decayTime_);

	Out.ar(~reverbOut, Pan2.ar(sig, pan_));
}).add;

SynthDef(\fm, {
	var t = In.ar(~t);
	var trig = In.ar(~triggerBus);

	var freq_ = BufRd.kr(1, Latch.ar(\freq.ar(), trig), t * BufFrames.kr(\freq.ar())).clip(20, 20000);
	var amp_ = BufRd.kr(1, Latch.ar(\amp.ar(), trig), t * BufFrames.kr(\amp.ar())).clip(0, 1);
	var pan_ = BufRd.kr(1, Latch.ar(\pan.ar(), trig), t * BufFrames.kr(\pan.ar())).clip(-1, 1);

	var ratio_ = BufRd.kr(1, Latch.ar(\ratio.ar(), trig), t * BufFrames.kr(\ratio.ar()));
	var index_ = BufRd.kr(1, Latch.ar(\index.ar(), trig), t * BufFrames.kr(\index.ar()));

	var env = Linen.kr(\gate.kr(1), ~fadeInTime, 1, ~fadeOutTime, 2);

	var modFreq = freq_*ratio_;
	var mod = SinOsc.ar(modFreq)*index_;
	var sig = SinOsc.ar(freq_ + mod) * amp_ * env;

	Out.ar(~reverbOut, Pan2.ar(sig, pan_));
}).add;

SynthDef(\sawDFMdelay, {
	var t = In.ar(~t);
	var trig = Changed.ar(t, 0.1);

	var freq_ = BufRd.kr(1, Latch.ar(\freq.ar(), trig), t * BufFrames.kr(\freq.ar())).clip(20, 20000);
	var dtune_ = BufRd.kr(1, Latch.ar(\dtune.ar(), trig), t * BufFrames.kr(\dtune.ar()));
	var width_ = BufRd.kr(1, Latch.ar(\width.ar(), trig), t * BufFrames.kr(\width.ar()));
	var amp_ = BufRd.kr(1, Latch.ar(\amp.ar(), trig), t * BufFrames.kr(\amp.ar())).clip(0, 1);
	var pan_ = BufRd.kr(1, Latch.ar(\pan.ar(), trig), t * BufFrames.kr(\pan.ar())).clip(-1, 1);

	var cutoff_ = BufRd.kr(1, Latch.ar(\cutoff.ar(), trig), t * BufFrames.kr(\cutoff.ar()));
	var res_ = BufRd.kr(1, Latch.ar(\res.ar(), trig), t * BufFrames.kr(\res.ar())).clip(0.01, 5);
	var gain_ = BufRd.kr(1, Latch.ar(\gain.ar(), trig), t * BufFrames.kr(\gain.ar()));

	var delayTime_ = BufRd.kr(1, Latch.ar(\delayTime.ar(), trig), t * BufFrames.kr(\delayTime.ar()));
	var decayTime_ = BufRd.kr(1, Latch.ar(\decayTime.ar(), trig), t * BufFrames.kr(\decayTime.ar()));

	var env = Linen.kr(\gate.kr(1), ~fadeInTime, 1, ~fadeOutTime, 2);

	var sig = VarSaw.ar(freq_, 0, width_) + VarSaw.ar(freq_+dtune_, 0.5, width_);

	sig = AllpassC.ar(sig, ~maxDelayTime, delayTime_, decayTime_);
	sig = DFM1.ar(sig, cutoff_, res_, gain_) * amp_ * env;

	Out.ar(~reverbOut, Pan2.ar(sig, pan_));
}).add;


SynthDef(\timer, {
	|dur = 1, loopPoint = 1, t_manualTrig = 0, startPoint = 0|

	var sig = Phasor.ar(
		t_manualTrig,
		1/(dur*SampleRate.ir()),
		startPoint,
		//set loopPoint to 1 for looping, inf for no looping
		loopPoint,
		startPoint
	);

	/*
	When the new cycle starts and the new buffers
	(which have already been received) are activated,
	then release the previous buffers and ask for the next batch
	*/
	var trigStart = Changed.ar(sig, 0.01);
	var trigFreeOld = TDelay.ar(trigStart, 0.001);
	var trigAskNext = TDelay.ar(trigStart, 0.002);

	// Trigger for asking for next batch of buffers
	SendTrig.ar(trigAskNext, 1, sig);
	// Trigger for releasing old buffers
	SendTrig.ar(trigFreeOld, 0, sig);
	SendTrig.ar(trigStart, 2);

	Out.ar(~triggerBus, trigStart);
	Out.kr(~silencerBus, sig);
	Out.ar(~t, sig.clip(0, 1));
}).add;

SynthDef(\silencer, {
	var phasor = In.kr(~silencerBus);
	var reverbIn = In.ar(~reverbOut, 2);
	var dryIn = In.ar(~dryOut, 2);

	var switch = Lag2.kr(phasor < 1);
	reverbIn = reverbIn * switch;
	dryIn = dryIn * switch;
	Out.ar(~reverbSilencedBus, reverbIn);
	Out.ar(0, dryIn);
}).add;

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

/*
SynthDef(\noise, {
	arg amp, freq, rq, pan;

	var freq_ = BufRd.kr(1, freq, In.ar(~t) * BufFrames.kr(freq));
	var amp_ = BufRd.kr(1, amp, In.ar(~t) * BufFrames.kr(amp));
	var pan_ = BufRd.kr(1, pan, In.ar(~t) * BufFrames.kr(pan));
	var rq_ = BufRd.kr(1, rq, In.ar(~t) * BufFrames.kr(rq));

	var fade = Env([0, 1], [~fadeTime], \sine).kr(0);
	var sig = WhiteNoise.ar();
	sig = RLPF.ar(sig, freq_, rq_) * amp_ * fade;

	Out.ar(~reverbOut, Pan2.ar(sig, pan_));
}).add;

SynthDef(\sine, {
	arg amp, freq, pan;

	var freq_ = BufRd.kr(1, freq, In.ar(~t) * BufFrames.kr(freq));
	var amp_ = BufRd.kr(1, amp, In.ar(~t) * BufFrames.kr(amp));
	var pan_ = BufRd.kr(1, pan, In.ar(~t) * BufFrames.kr(pan));

	var fade = Env([0, 1], [~fadeTime], \sine).kr(0);
	var sig = SinOsc.ar(freq_) * amp_*fade*fade;

	Out.ar(~reverbOut, Pan2.ar(sig, pan_));
}).add;

SynthDef(\fm, {
	arg amp, freq, ratio, index, pan;

	var freq_ = BufRd.kr(1, freq, In.ar(~t) * BufFrames.kr(freq));
	var ratio_ = BufRd.kr(1, ratio, In.ar(~t) * BufFrames.kr(ratio));
	var index_ = BufRd.kr(1, index, In.ar(~t) * BufFrames.kr(index));
	var amp_ = BufRd.kr(1, amp, In.ar(~t) * BufFrames.kr(amp));
	var pan_ = BufRd.kr(1, pan, In.ar(~t) * BufFrames.kr(pan));

	var fade = Env([0, 1], [~fadeTime], \sine).kr(0);

	var modFreq = freq_*ratio_;
	var mod = SinOsc.ar(modFreq)*index_;
	var sig = SinOsc.ar(freq_ + mod) * amp_*fade*fade;

	Out.ar(~reverbOut, Pan2.ar(fade* fade*fade * sig, pan_));
}).add;

SynthDef(\fm2Parallel, {
	arg amp, freq, ratio1, index1, ratio2, index2, pan;

	var freq_ = BufRd.kr(1, freq, In.ar(~t) * BufFrames.kr(freq));
	var ratio1_ = BufRd.kr(1, ratio1, In.ar(~t) * BufFrames.kr(ratio1));
	var index1_ = BufRd.kr(1, index1, In.ar(~t) * BufFrames.kr(index1));
	var ratio2_ = BufRd.kr(1, ratio2, In.ar(~t) * BufFrames.kr(ratio2));
	var index2_ = BufRd.kr(1, index2, In.ar(~t) * BufFrames.kr(index2));
	var amp_ = BufRd.kr(1, amp, In.ar(~t) * BufFrames.kr(amp));
	var pan_ = BufRd.kr(1, pan, In.ar(~t) * BufFrames.kr(pan));

	var fade = Env([0, 1], [~fadeTime], \sine).kr(0);

	var modFreq1 = freq_*ratio1_;
	var modFreq2 = freq_*ratio2_;
	var mod1 = SinOsc.ar(modFreq1)*index1_;
	var mod2 = SinOsc.ar(modFreq2)*index2_;
	var sig = SinOsc.ar(freq_ + mod1 + mod2) * amp_;

	Out.ar(~reverbOut, Pan2.ar(fade * sig, pan_));
}).add;

SynthDef(\fm2Series, {
	arg amp, freq, ratio1, index1, ratio2, index2, pan;

	var freq_ = BufRd.kr(1, freq, In.ar(~t) * BufFrames.kr(freq));
	var ratio1_ = BufRd.kr(1, ratio1, In.ar(~t) * BufFrames.kr(ratio1));
	var index1_ = BufRd.kr(1, index1, In.ar(~t) * BufFrames.kr(index1));
	var ratio2_ = BufRd.kr(1, ratio2, In.ar(~t) * BufFrames.kr(ratio2));
	var index2_ = BufRd.kr(1, index2, In.ar(~t) * BufFrames.kr(index2));
	var amp_ = BufRd.kr(1, amp, In.ar(~t) * BufFrames.kr(amp));
	var pan_ = BufRd.kr(1, pan, In.ar(~t) * BufFrames.kr(pan));

	var fade = Env([0, 1], [~fadeTime], \sine).kr(0);

	var modFreq1 = freq_*ratio1_;
	var modFreq2 = freq_*ratio2_;
	var mod1 = SinOsc.ar(modFreq1)*index1_;
	var mod2 = SinOsc.ar(modFreq2+mod1)*index2_;
	var sig = SinOsc.ar(freq_ + mod2) * amp_;

	Out.ar(~reverbOut, Pan2.ar(fade * sig, pan_));
}).add;

SynthDef(\fm4, {
	arg amp, freq1, freq2, ratio1, index1, ratio2, index2, pan;

	var freq1_ = BufRd.kr(1, freq1, In.ar(~t) * BufFrames.kr(freq1));
	var freq2_ = BufRd.kr(1, freq2, In.ar(~t) * BufFrames.kr(freq2));
	var ratio1_ = BufRd.kr(1, ratio1, In.ar(~t) * BufFrames.kr(ratio1));
	var index1_ = BufRd.kr(1, index1, In.ar(~t) * BufFrames.kr(index1));
	var ratio2_ = BufRd.kr(1, ratio2, In.ar(~t) * BufFrames.kr(ratio2));
	var index2_ = BufRd.kr(1, index2, In.ar(~t) * BufFrames.kr(index2));
	var amp_ = BufRd.kr(1, amp, In.ar(~t) * BufFrames.kr(amp));
	var pan_ = BufRd.kr(1, pan, In.ar(~t) * BufFrames.kr(pan));

	var fade = Env([0, 1], [~fadeTime], \sine).kr(0);

	var mod1 = SinOsc.ar(freq1_*ratio1_)*index1_ * fade;
	var mod2 = SinOsc.ar(freq2_*ratio2_)*index2_ * fade;
	var car1 = SinOsc.ar(freq1_ + mod1) * fade;
	var car2 = SinOsc.ar(freq2_ + mod2) * fade;
	var sig = (car1 + car2) * 0.5 * amp_ * fade;

	Out.ar(~reverbOut, Pan2.ar(fade * sig, pan_));
}).add;



~noiseFreq = 0.8;
~lagTime = 0.8;
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

SynthDef(\sine, {
	arg amp, freq, pan;

	var amp_ = BufRd.kr(1, amp, In.ar(~t) * BufFrames.kr(amp));
	var freq_ = BufRd.kr(1, freq, In.ar(~t) * BufFrames.kr(freq));
	var pan_ = BufRd.kr(1, pan, In.ar(~t) * BufFrames.kr(pan));

	var sig = SinOsc.ar(freq_) * amp_;
	Out.ar(~reverbOut, Pan2.ar(sig, pan_));
}).add;

*/

"TimeLines: SynthDefs loaded".postln;
)