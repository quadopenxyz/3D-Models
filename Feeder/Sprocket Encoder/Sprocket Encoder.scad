
/*[Parts to Render]*/
Render_Slits = true;
Render_Wheel = true;
Render_Wheel_Extrude = true;
Render_Wheel_Mounts = true;
Render_Pins = true;

/*[Wheel Params]*/
Wheel_OD = 33;//[0:0.1:35]

/*[Encoder Params]*/
Encoder_Slit_Count = 28;//[28,56]

/*[Pin Params]*/
Pin_Length = 2;//[0:.01:5]
Pin_Width = 1;//[0:.01:5]

/*[Hidden]*/
MH_ID = 3.4;

Wheel_ID = 3.3;
Wheel_Height = 1;//[0:0.1:5]

Encoder_OD = Wheel_OD - 1.2;
Encoder_ID = Encoder_OD - 3.6;

Pin_Count = 28;

$fn=200;

Wheel_ID_Radius = Wheel_ID/2;
Wheel_OD_Radius = Wheel_OD/2;

w = (Pin_Count == 28 ? 7.5 : 6.5); // imperically determined... better math welcome
encoderSlitWidth = ((360/Encoder_Slit_Count) / w );
encoderInnerRadius = Encoder_ID/2;
encoderOuterRadius = Encoder_OD/2;
encoderSlitLength = encoderOuterRadius-encoderInnerRadius;

module DrawSlit()
{
	hull()
	{
		translate([encoderSlitLength/3.141,0,0])
			cylinder(d=encoderSlitWidth, h=Wheel_Height+.1, center = true);
		translate([-encoderSlitLength/3.141,0,0])
			cylinder(d=encoderSlitWidth, h=Wheel_Height+.1, center = true);
	}
}

pollyPointsPin = 
[
	[0,0],
	[0,Pin_Length*.70],
	[Pin_Width - (Pin_Width*.7), Pin_Length],
	[Pin_Width,Pin_Length],
	[Pin_Width - (Pin_Width*.3), Pin_Length],
	[Pin_Width,Pin_Length*.70],
	[Pin_Width,0],
];

module DrawPin()
{
	//cube([Pin_Width,Pin_Length,Wheel_Height+.1], center=true);
	translate ([-Pin_Width/2, -Pin_Length/2, 0])
		polygon(points=pollyPointsPin);
}

pollyPointsWheel = [
	[Wheel_OD_Radius,0],
	[Wheel_OD_Radius,Wheel_Height],
	[Wheel_ID_Radius,Wheel_Height],
	[Wheel_ID_Radius,0],
	];

module wheel()
{
	difference ()
	{
		if(Render_Wheel)
		{
			if(Render_Wheel_Extrude)
				rotate_extrude($fn=200)
					polygon(points=pollyPointsWheel);
			else 
				polygon(points=pollyPointsWheel);
		}

		if(Render_Slits && ( Render_Wheel_Extrude || !Render_Wheel))
		{
			for(i=[0:Encoder_Slit_Count-1])
				rotate(a = [0,0,(360/Encoder_Slit_Count)*i])
					translate(v=[0, encoderInnerRadius+(encoderSlitLength/2)-.5, 0])
						translate([0, Wheel_Height/4, (Wheel_Height/2)])
							rotate([0,0,90])
								DrawSlit();
		}
		
		// The mounting holes
		if(Render_Wheel_Mounts)
		{
			y = 8 - ((MH_ID + Wheel_ID) / 2); // distance from shaft center to MH center
			for(t=[0,120,240])
				rotate(t)
					translate([0, y, Wheel_Height/2])
						cylinder(d1=MH_ID, d2=MH_ID*1.5, h=Wheel_Height+.1, center=true);
		}
	}
	if(Render_Pins && ( Render_Wheel_Extrude || !Render_Wheel))
	{
		for(i=[0:Pin_Count-1])
			rotate(a = [0,0,(360/Pin_Count)*i])
				translate(v=[0, Wheel_OD_Radius + (Pin_Length/2), 0])
					translate([0, 0, (Wheel_Height/2)])
						DrawPin();
	}
}

{
	wheel();
}

