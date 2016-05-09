s.boot;
s.options.device="AudioBox VSL ASIO Driver";
s.sampleRate;


(
s.record;
//b = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav"); // remember to free the buffer later.
b = Buffer.alloc(s, s.sampleRate, 1);
b.bufnum;

x = {arg rec=1; RecordBuf.ar(SoundIn.ar(0), 1, 0, run:rec, preLevel:0.5, loop:1)}.play;
a = {arg rate=1; PlayBuf.ar(1, 1, rate, loop:1)}.play;

//b=1;
//x = {arg rate=1; RecordBuf.ar(SoundIn.ar(0), b, 0, preLevel:0.5, loop:0)}.play;
//x = {RecordBuf.ar(SoundIn.ar(0),1, 0, preLevel:0.5, loop:1)}.play;
//z={PlayBuf.ar(1,1,1,0,0,1,0)}.play;

x.free;
b.free;
//z.free;


)

x.set(\rec,0)




(

s.record;
~tiemporeal={
arg rec;
var sig;

//Establecer señal de entrada
	sig=SoundIn.ar(0);
//sig=RecordBuf.ar(SoundIn.ar(0),1, 0,run:1, preLevel:0.5, loop:1);
//non feedback output to speakers
	//z={PlayBuf.ar(1,1,1,0,0,1,0)};

	Out.ar(0,sig);

}.play;
)

~tiemporeal.set(\rec,0)
~tiemporeal.free;



)

(
SynthDef(\recbuf, {arg buffer, preLevel=0;
	RecordBuf.ar(SoundIn.ar(0), buffer, 0,recLevel:1, preLevel:preLevel,run:1, loop:1);
}).add;

SynthDef(\playbuf, {arg buffer, out=0, rate=1, amp=1;
	var signal;
	signal = PlayBuf.ar(1, buffer, rate:rate, loop:1) * amp;
	Out.ar(out, Pan2.ar(signal, 0));
}).add;

b=1;
Synth(\recbuf, [\buffer, b])
Synth(\playbuf, [\buffer, b, \rate, 1])


)





// APAGADO DE MICROFONOS:



(
a.free;
b.free;
c.free;
d.free;
)
(
//ACTIVAR SISTEMA


a=Synth.new(\track,["id", 1]);
b=Synth.new(\track,["id", 2]);
c=Synth.new(\track,["id", 3]);
d=Synth.new(\track,["id", 4]);
)

f = NetAddr.new("192.168.0.11", 57120);
s.meter;





(
////////////////////// DEFINICION DE ENTRADAS DE MICS///////////////////////
//s.meter;






SynthDef(\track, {
    arg id ,x=0,y=0,vol=1,feedback=0.1,gate_rev=0,rec=0;
	var sig,sig_out,local,delay;

    //sig=SoundIn.ar(0);
   // local=LocalIn.ar(1)+sig;
	//Reverberar
 //   10.do{local=AllpassN.ar(local,0.06,Rand(0.001,0.06),5)};
   // LocalOut.ar(local*feedback);



	sig_out=RecordBuf.ar(SoundIn.ar(0),0,0,1,0,1,1,0);

	Out.ar(0, Pan4.ar(sig_out,x ,y, vol))

	//Out.ar(0, Pan4.ar(sig+(local*gate_rev),xpos ,ypos, vol))

}).add;




////////////////////////////////////////////////////////
////////////////////// OSC DEF /////////////////////////
////////////////////////////////////////////////////////


////////////////////// TRACKS /////////////////////////


OSCdef.new(
	\track_1,
	{
		arg msg,time,addr,port;


		if(msg[1]==1,{
			~track = 1;
			//~track.postln;

			//prueba de hacer un id generico
((96+id).asAscii).get(\id,{arg ide; "id: ".post;ide.post});


			a.get(\id,{arg ide; "id: ".post;ide.post});
			a.get(\vol, { arg vol;  f.sendMsg("/vol", vol); });
			a.getn(\x,2,{arg xy;x=xy[0];y=xy[1];f.sendMsg("/xy", x,y); });


			f.sendMsg("/led_1", 1);
			f.sendMsg("/led_2", 0);
			f.sendMsg("/led_3", 0);
			f.sendMsg("/led_4", 0);
			}


		);

	},
	'/track_1'


);

OSCdef.new(
	\track_2,
	{
		arg msg,time,addr,port;


		if(msg[1]==1,{
			~track = 2;
			~track.postln;

			b.get(\vol, {arg vol;  f.sendMsg("/vol", vol); });
			b.getn(\x,2,{arg xy;x=xy[0];y=xy[1];f.sendMsg("/xy", x,y); });

			f.sendMsg("/led_1", 0);
			f.sendMsg("/led_2", 1);
			f.sendMsg("/led_3", 0);
			f.sendMsg("/led_4", 0);
			}

		);

	},
	'/track_2'
);

OSCdef.new(
	\track_3,
	{
		arg msg,time,addr,port;


		if(msg[1]==1,{
			~track = 3;
			~track.postln;

			c.get(\id,c);
			c.get(\vol, {arg vol;  f.sendMsg("/vol", vol); });
			c.getn(\x,2,{arg xy;x=xy[0];y=xy[1];f.sendMsg("/xy", x,y); });

			f.sendMsg("/led_1", 0);
			f.sendMsg("/led_2", 0);
			f.sendMsg("/led_3", 1);
			f.sendMsg("/led_4", 0);


			}
		);

	},
	'/track_3'
);

OSCdef.new(
	\track_4,
	{
		arg msg,time,addr,port,z;



		if(msg[1]==1,
			~track = 4;{
			~track.postln;

			//d.set(\ident,88);
			d.get(\vol, {arg vol;  f.sendMsg("/vol", vol); });


			d.getn(\x,2,{arg xy;x=xy[0];y=xy[1];f.sendMsg("/xy", x,y); });

			f.sendMsg("/led_1", 0);
			f.sendMsg("/led_2", 0);
			f.sendMsg("/led_3", 0);
			f.sendMsg("/led_4", 1);


			}
			);

	},
	'/track_4'
);


/////////////////// POSICIONES ///////////////////

OSCdef.new(
	\xy,
	{arg msg, time, addr, port  ;

// habria que hacer una clase que se llame current track y que tenga el id de la pista seleccionada....
		// en esa misma clase hacer la transformacion de numero a letra.... y aca levantar esa ide(en letra ) con un get y usarla para los set de posición

		switch (~track,
			1,{a.set(\x,msg[1]); a.set(\y,msg[2]);"X1: ".post ;msg[1].postln; "Y1: ".post ;msg[1].postln},
			2,{b.set(\x,msg[1]); b.set(\y,msg[2]);"X2: ".post ;msg[1].postln; "Y2: ".post ;msg[2].postln},
			3,{c.set(\x,msg[1]); c.set(\y,msg[2]);"X3: ".post ;msg[1].postln; "Y3: ".post ;msg[2].postln},
			4,{d.set(\x,msg[1]); d.set(\y,msg[2]);"X4: ".post ;msg[1].postln; "Y4: ".post ;msg[2].postln}
		);



	},
	'/xy'
);




////////////////////// VOLUMENES ////////////////////


OSCdef.new(
	\vol,
	{arg msg, time, addr, port  ;


		switch (~track,
			1,{a.set(\vol,msg[1]); "volumen pista 1: ".post; msg[1].postln;},
			2,{b.set(\vol,msg[1]); "volumen pista 2: ".post; msg[1].postln;},
			3,{c.set(\vol,msg[1]); "volumen pista 3: ".post; msg[1].postln;},
			4,{d.set(\vol,msg[1]); "volumen pista 4: ".post; msg[1].postln;}
		);


	},
	'/vol'
);


////////////////////// RECORD ////////////////////



OSCdef.new(
	\rec,
	{arg msg, time, addr, port;


		switch (~track,
			1,{
			a.get(\rec, {arg rec;if(msg[1]==1 && rec == 0, {a.set(\rec,1); f.sendMsg("/led_rec_1", 1) } );  if(msg[1]==1 && rec == 1, {a.set(\rec,0);f.sendMsg("/led_rec_1", 0)} );});
			},
			2,{
			b.get(\rec, {arg rec;if(msg[1]==1 && rec == 0, {b.set(\rec,1); f.sendMsg("/led_rec_2", 1) } );  if(msg[1]==1 && rec == 1, {b.set(\rec,0);f.sendMsg("/led_rec_2", 0)} );});
			},
			3,{
			c.get(\rec, {arg rec;if(msg[1]==1 && rec == 0, {c.set(\rec,1); f.sendMsg("/led_rec_3", 1) } );  if(msg[1]==1 && rec == 1, {c.set(\rec,0);f.sendMsg("/led_rec_3", 0)} );});
			},
			4,{
			d.get(\rec, {arg rec;if(msg[1]==1 && rec == 0, {d.set(\rec,1); f.sendMsg("/led_rec_4", 1) } );  if(msg[1]==1 && rec == 1, {d.set(\rec,0);f.sendMsg("/led_rec_4", 0)} );});
			}
		);

	},
	'/rec'
);



/*

La idea seria armar una clase que que contenga los valores de la pista actual....

... con estos setear los valores del synth def...
*/








///////////////////////////// FALTA //////////////////////
/*
OSCdef.new(
	\rev,
	{
		arg msg,time,addr,port;
		msg.postln;
		if(msg[1]==1,{a.set(\gate_rev,1)},{a.set(\gate_rev,0)});
	},
	'/rev'
);


*/





)

























