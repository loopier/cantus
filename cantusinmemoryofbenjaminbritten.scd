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
		sig = RHPF.ar(sig, env.range(filterfreq/2,filterfreq*2), 0.02, 0.5);
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
		sig = RLPF.ar(sig, filterfreq, 0.2, 0.5);
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
// Given an iterative descendant scale, move one octave down per iteration
var octavate_down = {|note,index|
	var octave = (index/melody_tintinnabuli.size).asInt;
	note - (7*octave);
};

var descendant_scale = Array.series(8,7,-1); // one octave down, from root to root
var melody = descendant_scale.pyramid(1); // [a, a, b, a, b, c, ...]
var melody_tintinnabuli = melody.collect(tintinnabulifunc); // add Tintinnabuli to the melody

// Melody for Violin #1: Down 2 octaves, ending on third degree of the 3rd octave down (A6 to C4)
var melody1 = Array.series((7*3)-1,7*3,-1).pyramid(1).collect(tintinnabulifunc);
// Melody for Violin #2: Down 2 octaves, ending on root (A5 to A3)
var melody2 = (melody_tintinnabuli.wrapExtend(melody_tintinnabuli.size*2)).collect(octavate_down);
// Melody for Viola: Down 1 octave ending on the fifth degree of the 2nd octave down (A4 to E3) -- Voice without Tintinnabuli
var melody3 = (melody.wrapExtend((melody.size*2)-4)).collect(octavate_down);
// Melody for Cello and Bass: Down 1 octave ending on root
var melody4 = melody_tintinnabuli;
var melody5 = melody_tintinnabuli;

// alternate half and quarter notes
// var dur = Array.fill(melody.size, {|i| (i.mod(2)+1)/2}).reverse;
// var base_dur = [3,[2,1],1].convertRhythm; // alternate half and quarter notes
var dur1 = Array.fill(melody1.size, {|i| (i.mod(2)+1)/2;}).reverse;
var dur2 = Array.fill(melody2.size, {|i| (i.mod(2)+1)/2;}).reverse;
var dur3 = Array.fill(melody3.size, {|i| (i.mod(2)+1)/2;}).reverse;
var dur4 = Array.fill(melody4.size, {|i| (i.mod(2)+1)/2;}).reverse;
var dur5 = Array.fill(melody5.size, {|i| (i.mod(2)+1)/2;}).reverse;

var amp = Array.series(melody.size, 0.05, 0.2/melody.size); // alternate [1,1/2]
var root = -3;
var violin1 = Pbind(\instrument, \brutb, \root, root, \scale, Scale.minor, \lag, 0.1,
	\octave, 7,
	\attack, 0.5,
	\filterfreq, 8600,
	\amp, Pseq(/*[0]++*/Array.series(dur1.size-1, 0.05, 0.2/(dur1.size-1))++[0.0015])/4,
	\dur, Pseq(/*[3]++*/dur1.put(dur1.size-1, 274.5)), // set longer dur for last note
	\degree, Pseq(/*[0]++*/melody1)
);
var violin2 = Pbind(\instrument, \brutb, \root, root, \scale, Scale.minor, \lag, 0.1,
	\octave, 6,
	\pan, -0.5,
	\attack, 1,
	\release, 2,
	\filterfreq, 600,
	\amp, Pseq(/*[0]++*/Array.series(dur2.size-1, 0.05, 0.2/(dur2.size-1))++[0.0015])/6,
	\dur, Pseq(/*[6]++*/dur2.put(dur2.size-1, 324)*2),
	\degree, Pseq(/*[0]++*/melody2)
);
var viola = Pbind(\instrument, \brutb, \root, root, \scale, Scale.minor, \lag, 0.1,
	\octave, 5,
	\pan, 0.5,
	\attack, 2,
	\release, 4,
	\amp, Pseq(/*[0]++*/Array.series(dur3.size-1, 0.05, 0.2/(dur3.size-1))++[0.003])/6,
	\dur, Pseq(/*[12]++*/dur3.put(dur3.size-1,228)*4),
	\degree, Pseq(/*[0]++*/melody3)
);
var cello = Pbind(\instrument, \brutb, \root, root, \scale, Scale.minor, \lag, 0.1,
	\octave, 4,
	\attack, 4,
	\release, 8,
	\filterfreq, 400,
	\scale, Scale.minor,
	\amp, Pseq(/*[0]++*/Array.series(dur4.size-1, 0.05, 0.2/(dur4.size-1))++[0.003])/12,
	\dur, Pseq(/*[18]++*/dur4.put(dur4.size-1,216)*8),
	\degree, Pseq(/*[0]++*/melody4)
);
var bass = Pbind(\instrument, \brutb, \root, root, \scale, Scale.minor, \lag, 0.1,
	\octave, 3,
	\attack, 8,
	\release, 16,
	\filterfreq, 600,
	\scale, Scale.minor,
	\amp, Pseq(/*[0]++*/Array.series(dur5.size-1, 0.05, 0.2/(dur5.size-1))++[0.0015])/6,
	\dur, Pseq(dur5*16),//Pseq(/*[24]++*/(dur5.put(dur5.size-1,8))*16)/4,
	\degree, Pseq(/*[0]++*/melody5)
);

/*Ppar(
	[violin1, violin2, viola, cello, bass],
	// [violin1],
	1
).play;*/

Pspawner({|sp|
	sp.wait(1.5);
	sp.par(violin1);
	sp.wait(1.5);
	sp.par(violin2);
	sp.wait(6);
	sp.par(viola);
	sp.wait(12);
	sp.par(cello);
	sp.wait(24);
	sp.par(bass);
	/*sp.wait(1.6);
	sp.suspendAll;*/
}).play;
)