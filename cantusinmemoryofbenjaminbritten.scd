/*
*  Cantus in Memory of Benjamin Britte
*
*  Composed by Arvo Pärt
*
*  Code by Roger Pibernat (Dec 2014)
*/

// Evalua primer això...
// Evaluate this first...
(
s.waitForBoot({
	// violins
	SynthDef(\bruta, {|amp=0.2, freq=261.62, filterfreq=1500, pan=0, out=0, gate=1, attack=0.01, decay=0.3, sustain=0.5, release=1|
		var sig, env;
		sig = LFSaw.ar(freq,[0,0.2,0.6])
		+ LFSaw.ar(freq/2, 0.5.rand, 0.6)
		+ LFSaw.ar(freq*1.4983070768767, 0.5.rand, 0.3);
		env = EnvGen.kr(Env.adsr(attack,decay, sustain, release), gate, doneAction:2);
		sig = RLPF.ar(sig, env.range(filterfreq/2,filterfreq*2), 0.02, 0.5);
		sig = sig * amp;
		sig = sig * env;
		Out.ar(out, Pan2.ar(sig.sum, pan));
	}).add;

	// viola, cello and bass
	SynthDef(\brutb, {|amp=0.2, freq=261.62, filterfreq=1500, pan=0, out=0, gate=1, attack=0.01, decay=0.3, sustain=0.5, release=1|
		var sig, env;
		sig = LFSaw.ar(freq,[0,0.2,0.6])
		+ LFSaw.ar(freq/2, 0.5.rand, 0.6)
		+ LFSaw.ar(freq*1.4983070768767, 0.5.rand, 0.3);
		env = EnvGen.kr(Env.adsr(attack,decay, sustain, release), gate, doneAction:2);
		sig = RLPF.ar(sig, filterfreq, env.range(0.9,0.7), 0.5);
		sig = sig * amp;
		sig = sig * env;
		Out.ar(out, Pan2.ar(sig, pan));
	}).add;

	// Oscilloscope on X/Y mode for 2 channels
	s.scope(2).style_(2).window.bounds_(Rect(0,1024,400,400));
})
)


// ... i llavors evalua això
// ... then evaluate this
(
// Given a note, return an array(2) of the note and its Tintinnabuli T1d (closest triad note below the current note)
var tintinnabulifunc = {|note|
	var octave = (note/7).asInt;
	var tintinnabuli = switch(note.mod(7), // degree
		0, {-3}, // root
		1, {0},
		2, {0}, // third
		3, {2},
		4, {2}, // fifth
		5, {4},
		6, {4}
	);
	tintinnabuli = tintinnabuli + (7*octave);
	[note, tintinnabuli]
};

var descendant_scale = Array.series(8,7,-1); // one octave down, from root to root
var melody = descendant_scale.pyramid(1); // [a, a, b, a, b, c, ...]
var melody_tintinnabuli = melody.collect(tintinnabulifunc); // add Tintinnabuli to the melody

// Melody for Violin #1: Down 2 octaves, ending on third degree of the 3rd octave down (A6 to C4)
var melody1 = melody_tintinnabuli.wrapExtend((melody_tintinnabuli.size*3)-2);
// Melody for Violin #2: Down 2 octaves, ending on root (A5 to A3)
var melody2 = melody_tintinnabuli.wrapExtend(2);
// Melody for Viola: Down 1 octave ending on the fifth degree of the 2nd octave down (A4 to E3) -- Voice without Tintinnabuli
var melody3 = melody.wrapExtend((melody_tintinnabuli.size*2)-4);
// Melody for Cello and Bass: Down 1 octave ending on root
var melody4 = melody_tintinnabuli;
var meldoy5 = meldoy_tintinnabuli;

// var dur = Array.fill(melody.size, {|i| (i.mod(2)+1)/2}).reverse; // alternate [1,1/2]
// var base_dur = [3,[2,1],1].convertRhythm; // alternate half and quarter notes
// var dur1 = Array.fill(melody1.size, {|i| i.mod(2)+1/2;}).reverse;
// var dur2 = Array.fill(melody2.size, {|i| if(i!=(melody2.size-1),{base_dur[i.mod(2)]},{20});});
// var dur3 = Array.fill(melody3.size, {|i| if(i!=(melody3.size-1),{base_dur[i.mod(2)]},{20});});
// var dur4 = Array.fill(melody4.size, {|i| if(i!=(melody4.size-1),{base_dur[i.mod(2)]},{20});});
// var dur5 = Array.fill(melody5.size, {|i| if(i!=(melody5.size-1),{base_dur[i.mod(2)]},{20});});

var amp = Array.series(melody.size, 0.05, 0.2/melody.size); // alternate [1,1/2]
var root = -3;
var violin1 = Pbind(\instrument, \bruta, \root, root, \scale, Scale.minor, \lag, 0.1,
	\octave, 7,
	\attack, 0.5,
	\filterfreq, 600,
	\amp, Pseq([0]++amp++(0.3!amp.size)++[0.003])/4,
	\dur, Pseq([3]++dur++dur++[185]),
	\degree, Pseq([0]++melody_tintinnabuli++melody_tintinnabuli++[0])
);
var violin2 = Pbind(\instrument, \bruta, \root, root, \scale, Scale.minor, \lag, 0.1,
	\octave, 6,
	\pan, -0.5,
	\attack, 0.5,
	\amp, Pseq([0]++amp++[0.003])/6,
	\dur, Pseq([6]++(dur*2)++[182]),
	\degree, Pseq([0]++melody_tintinnabuli++[2])
);
var viola = Pbind(\instrument, \brutb, \root, root, \scale, Scale.minor, \lag, 0.1,
	\octave, 5,
	\pan, 0.5,
	\attack, 0.5,
	\amp, Pseq([0]++amp++[0.005])/6,
	\dur, Pseq([12]++(dur*4)++[122]),
	\degree, Pseq([0]++melody++[4])
);
var cello = Pbind(\instrument, \brutb, \root, root, \scale, Scale.minor, \lag, 0.1,
	\octave, 4,
	\attack, 0.5,
	\filterfreq, 400,
	\scale, Scale.minor,
	\amp, Pseq([0]++amp++[0.005])/6,
	\dur, Pseq([18]++(dur*8)++[8]),
	\degree, Pseq([0]++melody_tintinnabuli++[0])
);
var bass = Pbind(\instrument, \brutb, \root, root, \scale, Scale.minor, \lag, 0.1,
	\octave, 3,
	\attack, 0.5,
	\filterfreq, 200,
	\scale, Scale.minor,
	\amp, Pseq([0]++amp++[0.005])/6,
	\dur, Pseq([24]++(dur*16)++[8]),
	\degree, Pseq([0]++melody_tintinnabuli++[0])
);

Ppar(
		[violin1, violin2, viola, cello, bass],
		// [violin2],
	1
).play
)