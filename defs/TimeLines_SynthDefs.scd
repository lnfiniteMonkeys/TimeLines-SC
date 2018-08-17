(
~fadeTime = 3;

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

SynthDef(\fm, {
	arg amp, freq, ratio, index, pan;

	var freq_ = BufRd.kr(1, freq, In.ar(~t) * BufFrames.kr(freq));
	var ratio_ = BufRd.kr(1, ratio, In.ar(~t) * BufFrames.kr(ratio));
	var index_ = BufRd.kr(1, index, In.ar(~t) * BufFrames.kr(index));
	var amp_ = BufRd.kr(1, amp, In.ar(~t) * BufFrames.kr(amp));
	var pan_ = BufRd.kr(1, pan, In.ar(~t) * BufFrames.kr(pan));

	var fade = Env([0, 1], [~fadeTime], \sine).kr(0);

	var mod = SinOsc.ar(freq_*ratio_)*index_;
	var sig = SinOsc.ar(freq_ + mod) * amp_*fade*fade;

	Out.ar(~reverbOut, Pan2.ar(fade* fade*fade * sig, pan_));
}).add;


SynthDef(\fm2, {
	arg amp, freq, ratio1, index1, ratio2, index2, pan;

	var freq_ = BufRd.kr(1, freq, In.ar(~t) * BufFrames.kr(freq));
	var ratio1_ = BufRd.kr(1, ratio1, In.ar(~t) * BufFrames.kr(ratio1));
	var index1_ = BufRd.kr(1, index1, In.ar(~t) * BufFrames.kr(index1));
	var ratio2_ = BufRd.kr(1, ratio2, In.ar(~t) * BufFrames.kr(ratio2));
	var index2_ = BufRd.kr(1, index2, In.ar(~t) * BufFrames.kr(index2));
	var amp_ = BufRd.kr(1, amp, In.ar(~t) * BufFrames.kr(amp));
	var pan_ = BufRd.kr(1, pan, In.ar(~t) * BufFrames.kr(pan));

	var fade = Env([0, 1], [~fadeTime], \sine).kr(0);

	var mod1 = SinOsc.ar(freq_*ratio1_)*index1_;
	var mod2 = SinOsc.ar(freq_*ratio2_)*index2_;
	var sig = SinOsc.ar(freq_ + mod1 + mod2) * amp_;

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

SynthDef(\sawDFM, {
	arg amp, freq, dtune, width, pan, ctf, res, gain;

	var freq_ = BufRd.kr(1, freq, In.ar(~t) * BufFrames.kr(freq));
	var dtune_ = BufRd.kr(1, dtune, In.ar(~t) * BufFrames.kr(dtune));
	var width_ = BufRd.kr(1, width, In.ar(~t) * BufFrames.kr(width));
	var amp_ = BufRd.kr(1, amp, In.ar(~t) * BufFrames.kr(amp));
	var pan_ = BufRd.kr(1, pan, In.ar(~t) * BufFrames.kr(pan));
	var ctf_ = BufRd.kr(1, ctf, In.ar(~t) * BufFrames.kr(ctf));
	var res_ = BufRd.kr(1, res, In.ar(~t) * BufFrames.kr(res));
	var gain_ = BufRd.kr(1, gain, In.ar(~t) * BufFrames.kr(gain));

	var fade = Env([0, 1], [~fadeTime]).kr(0);

	var sig = VarSaw.ar(freq_, 0, width_)*fade + VarSaw.ar(freq_+dtune_, 0.5, width_)*fade;
	//sig = (sig*pregain_).clip(-1, 1);
	sig = DFM1.ar(sig*fade, ctf_, res_, gain_) * amp_ * fade;
	Out.ar(~reverbOut, fade*Pan2.ar(sig*fade, pan_));
}).add;

~noiseFreq = 0.8;
~lagTime = 0.9;
SynthDef(\sine4, {
	|amp, amp1, freq1, amp2, freq2, amp3, freq3, amp4, freq4|

	var t  = In.ar(~t);
	var amp_ = BufRd.kr(1, amp, t * BufFrames.kr(amp));
	var amp1_ = BufRd.kr(1, amp1, t * BufFrames.kr(amp1));
	var freq1_ = BufRd.kr(1, freq1, t * BufFrames.kr(freq1));
	var amp2_ = BufRd.kr(1, amp2, t * BufFrames.kr(amp2));
	var freq2_ = BufRd.kr(1, freq2, t * BufFrames.kr(freq2));
	var amp3_ = BufRd.kr(1, amp3, t * BufFrames.kr(amp3));
	var freq3_ = BufRd.kr(1, freq3, t * BufFrames.kr(freq3));
	var amp4_ = BufRd.kr(1, amp4, t * BufFrames.kr(amp4));
	var freq4_ = BufRd.kr(1, freq4, t * BufFrames.kr(freq4));

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

"SynthDefs loaded".postln;
)