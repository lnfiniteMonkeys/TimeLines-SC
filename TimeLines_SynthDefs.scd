(
SynthDef(\phasor, {
	arg cycleDur = 1, r = 1;
	Out.ar(~t,   LFSaw.ar(cycleDur.reciprocal).range(0, r));
}).add;

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

	var freq_ = BufRd.kr(1, freq, In.ar(~t));
	var ratio_ = BufRd.kr(1, ratio, In.ar(~t));
	var index_ = BufRd.kr(1, index, In.ar(~t));
	var amp_ = BufRd.kr(1, amp, In.ar(~t));
	var pan_ = BufRd.kr(1, pan, In.ar(~t));

	var fade = Env([0, 1], [~fadeTime], \sine).kr(0);

	var mod = SinOsc.ar(freq_*ratio_)*index_;
	var sig = SinOsc.ar(freq_ + mod) * amp_*fade*fade;

	Out.ar(~reverbBus, Pan2.ar(fade* fade*fade * sig, pan_));
}).add;


SynthDef(\fm2, {
	arg amp, freq, ratio1, index1, ratio2, index2, pan;

	var freq_ = BufRd.kr(1, freq, In.ar(~t));
	var ratio1_ = BufRd.kr(1, ratio1, In.ar(~t));
	var index1_ = BufRd.kr(1, index1, In.ar(~t));
	var ratio2_ = BufRd.kr(1, ratio2, In.ar(~t));
	var index2_ = BufRd.kr(1, index2, In.ar(~t));
	var amp_ = BufRd.kr(1, amp, In.ar(~t));
	var pan_ = BufRd.kr(1, pan, In.ar(~t));

	var fade = Env([0, 1], [~fadeTime], \sine).kr(0);

	var mod1 = SinOsc.ar(freq_*ratio1_)*index1_;
	var mod2 = SinOsc.ar(freq_*ratio2_)*index2_;
	var sig = SinOsc.ar(freq_ + mod1 + mod2) * amp_;

	Out.ar(~reverbBus, Pan2.ar(fade * sig, pan_));
}).add;

SynthDef(\fm4, {
	arg amp, freq1, freq2, ratio1, index1, ratio2, index2, pan;

	var freq1_ = BufRd.kr(1, freq1, In.ar(~t));
	var freq2_ = BufRd.kr(1, freq2, In.ar(~t));
	var ratio1_ = BufRd.kr(1, ratio1, In.ar(~t));
	var index1_ = BufRd.kr(1, index1, In.ar(~t));
	var ratio2_ = BufRd.kr(1, ratio2, In.ar(~t));
	var index2_ = BufRd.kr(1, index2, In.ar(~t));
	var amp_ = BufRd.kr(1, amp, In.ar(~t));
	var pan_ = BufRd.kr(1, pan, In.ar(~t));

	var fade = Env([0, 1], [~fadeTime], \sine).kr(0);

	var mod1 = SinOsc.ar(freq1_*ratio1_)*index1_ * fade;
	var mod2 = SinOsc.ar(freq2_*ratio2_)*index2_ * fade;
	var car1 = SinOsc.ar(freq1_ + mod1) * fade;
	var car2 = SinOsc.ar(freq2_ + mod2) * fade;
	var sig = (car1 + car2) * 0.5 * amp_ * fade;

	Out.ar(~reverbBus, Pan2.ar(fade * sig, pan_));
}).add;

SynthDef(\sawDFM, {
	arg amp, freq, dtune, width, pan, ctf, res, gain;

	var freq_ = BufRd.kr(1, freq, In.ar(~t));
	var dtune_ = BufRd.kr(1, dtune, In.ar(~t));
	var width_ = BufRd.kr(1, width, In.ar(~t));
	var amp_ = BufRd.kr(1, amp, In.ar(~t));
	var pan_ = BufRd.kr(1, pan, In.ar(~t));
	var ctf_ = BufRd.kr(1, ctf, In.ar(~t));
	var res_ = BufRd.kr(1, res, In.ar(~t));
	var gain_ = BufRd.kr(1, gain, In.ar(~t));

	var fade = Env([0, 1], [~fadeTime]).kr(0);

	var sig = VarSaw.ar(freq_, 0, width_)*fade + VarSaw.ar(freq_+dtune_, 0.5, width_)*fade;
	//sig = (sig*pregain_).clip(-1, 1);
	sig = DFM1.ar(sig*fade, ctf_, res_, gain_) * amp_ * fade;
	Out.ar(~reverbBus, fade*Pan2.ar(sig*fade, pan_));
}).add;

~noiseFreq = 0.8;
~lagTime = 0.9;

SynthDef(\sine4, {
	arg amp, amp1, freq1, amp2, freq2, amp3, freq3, amp4, freq4;

	var amp_ = BufRd.kr(1, amp, In.ar(~t));
	var amp1_ = BufRd.kr(1, amp1, In.ar(~t));
	var freq1_ = BufRd.kr(1, freq1, In.ar(~t)).lag(~lagTime);
	var amp2_ = BufRd.kr(1, amp2, In.ar(~t));
	var freq2_ = BufRd.kr(1, freq2, In.ar(~t)).lag(~lagTime);
	var amp3_ = BufRd.kr(1, amp3, In.ar(~t));
	var freq3_ = BufRd.kr(1, freq3, In.ar(~t)).lag(~lagTime);
	var amp4_ = BufRd.kr(1, amp4, In.ar(~t));
	var freq4_ = BufRd.kr(1, freq4, In.ar(~t)).lag(~lagTime);

	var fade = Env([0, 1], [~fadeTime]).kr(0);

	var sin1 = Pan2.ar(SinOsc.ar(freq1_)*amp1_, LFNoise1.kr(~noiseFreq)) * fade * fade;
	var sin2 = Pan2.ar(SinOsc.ar(freq2_)*amp2_, LFNoise2.kr(~noiseFreq)) * fade * fade;
	var sin3 = Pan2.ar(SinOsc.ar(freq3_)*amp3_, LFNoise2.kr(~noiseFreq)) * fade * fade;
	var sin4 = Pan2.ar(SinOsc.ar(freq4_)*amp4_, LFNoise2.kr(~noiseFreq)) * fade * fade;

	var sig = (sin1 + sin2 + sin3 + sin4)/4 * amp_ * fade * fade;
	Out.ar(0, sig*fade);
}).add;

SynthDef(\sine, {
	arg amp, freq, pan;

	var amp_ = BufRd.kr(1, amp, In.ar(~t));
	var freq_ = BufRd.kr(1, freq, In.ar(~t));
	var pan_ = BufRd.kr(1, pan, In.ar(~t));


	var sig = SinOsc.ar(freq_) * amp_;
	Out.ar(0, Pan2.ar(sig, pan_));
}).add;
)