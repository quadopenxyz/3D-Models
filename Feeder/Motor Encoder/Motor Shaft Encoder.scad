// This is a tweaked mashup of;
// https://www.thingiverse.com/thing:156076/files
// https://www.thingiverse.com/thing:31363/files

/*[Parts to Render]*/
Render_Slits = true;
Render_Shaft = true;
Render_Shaft_Extrude = true;
Render_WormGear = true;
Render_D_Key = true;
Render_FDM_Support = false;

/*[Worm Params]*/
Worm_Pitch = 1.66;//[0:0.1:10]
Worm_Diameter = 9.6;//[0:0.1:20]
Worm_Height = 14;//[0:0.1:20]
Worm_Step = 10;
Worm_Elevation = 3;//[0:0.1:10]

/*[Shaft Params]*/
Shaft_ID = 2.1;//[0:0.01:10]
Shaft_OD = 4.75;//[0:0.01:10]
Shaft_Height = 25;//[0:0.1:30]
Shaft_Bevel = 0.3;//[0:0.1:5]

/*[Wheel Params]*/
Wheel_Diameter = 17;//[0:0.1:25]
Wheel_Height = 1.3;//[0:0.1:5]

Encoder_OD = 15;//[0:0.1:30]
Encoder_ID = 9.5;//[0:0.1:30]
Encoder_Slit_Count = 20;//[0:1:40]
Encoder_Slit_Type = 4;//[0:Rectangle, 1:Wedge, 2:Tilted Rectangle, 3:Tilted Wedge, 4:Rounded]

/*[Hidden]*/
$fn=200;

shaft_Radius = (Shaft_OD - Shaft_ID)/2;
shaft_ID_Radius = Shaft_ID/2;

wheel_Radius = Wheel_Diameter/2;
Wheel_Groove_Depth = 0.0;

encoderSlitWidth = (360/Encoder_Slit_Count) / Encoder_OD;
encoderInnerRadius = Encoder_ID/2;
encoderOuterRadius = Encoder_OD/2;
encoderSlitLength = encoderOuterRadius-encoderInnerRadius;

// https://www.thingiverse.com/thing:156076/files / Neal Horman / Steve Clynes
module DrawSlit()
{
  if (Encoder_Slit_Type == 0) // rectangle
  {
    cube(size = [encoderSlitWidth, encoderSlitLength, Wheel_Height+.1], center = true);
  }
  else if (Encoder_Slit_Type == 1) // wedge
  {
    translate([0, -encoderSlitLength / 2, 0 ])
		hull()
		{
			cube([encoderSlitWidth * .7, 0.01, Wheel_Height+.1], center = true);
			translate([0, encoderSlitLength, 0])
				cube([encoderSlitWidth * 1.3, 0.01, Wheel_Height+.1], center = true);
		}
  }
  else if (Encoder_Slit_Type == 2) // tilted rectangle
  {
    rotate(-15, [0, 0, 1])
      translate([0, 0.2, 0])
        cube(size = [encoderSlitWidth, encoderSlitLength * 1.2, Wheel_Height+.1], center = true);
  }
  else if (Encoder_Slit_Type == 3) // tilted wedge
  {
    rotate(-15, [0, 0, 1])
		translate([0, (-encoderSlitLength / 2) - 0.2, 0 ])
			hull()
			{
				cube([encoderSlitWidth * .7, 0.01, Wheel_Height+.1], center = true);
				translate([0, encoderSlitLength * 1.3, 0])
					cube([encoderSlitWidth * 1.3, 0.01, Wheel_Height+.1], center = true);
			}
  }
  else if (Encoder_Slit_Type == 4) // rounded
  {
    translate([0,Wheel_Height/4,0]) rotate([0,0,90]) hull()
    {
      translate([encoderSlitLength/3.141,0,0])
        cylinder(d=encoderSlitWidth, h=Wheel_Height+.1, center = true);
      translate([-encoderSlitLength/3.141,0,0])
        cylinder(d=encoderSlitWidth, h=Wheel_Height+.1, center = true);
    }
  }
}

// https://www.thingiverse.com/thing:156076/files
pollyPoints = [
	[shaft_ID_Radius+Shaft_Bevel,0],
	[wheel_Radius,0],
	[wheel_Radius-Wheel_Groove_Depth,Wheel_Height/2],
	[wheel_Radius,Wheel_Height],
	[shaft_ID_Radius+shaft_Radius,Wheel_Height],
	[shaft_ID_Radius+shaft_Radius,Shaft_Height],
	[shaft_ID_Radius+Shaft_Bevel,Shaft_Height],
	[shaft_ID_Radius,Shaft_Height-Shaft_Bevel],
	[shaft_ID_Radius,Shaft_Bevel],
	];

module wheel()
{
	difference ()
	{
		if(Render_Shaft)
		{
			if(Render_Shaft_Extrude)
				rotate_extrude($fn=200)
					polygon(points=pollyPoints);
			else 
				polygon(points=pollyPoints);
		}

		if(Render_Slits && ( Render_Shaft_Extrude || !Render_Shaft))
		{
			for(i=[0:Encoder_Slit_Count-1])
				rotate(a = [0,0,(360/Encoder_Slit_Count)*i])
					translate(v=[0, encoderInnerRadius+(encoderSlitLength/2), -.05])
						translate ([0, 0, (Wheel_Height/2)+.05]) 
							DrawSlit();
		}
	}
}


// https://www.thingiverse.com/thing:31363/files
// Metric Screw Thread Library
// by Maximilian Karl <karlma@in.tum.de> (2012)
// only use module thread(P,D,h,step)
module screwthread_triangle(P)
{
	difference()
	{
		translate([-sqrt(3)/3*P+sqrt(3)/2*P/8,0,0])
			rotate([90,0,0])
				cylinder(r=sqrt(3)/3*P,h=0.00001,$fn=3,center=true);

		translate([0,-P/2,-P/2])
			cube([P,P,P]);
	}
}

function screwDiamMin(P, D_maj) = D_maj - 5*sqrt(3)/8*P;

module screwthread_onerotation(P,D_maj,step)
{
	H = sqrt(3)/2*P;
	D_min = screwDiamMin(P, D_maj);

	for(i=[0:step:360-step])
	hull()
		for(j = [0,step])
			rotate([0,0,(i+j)])
				translate([D_maj/2,0,(i+j)/360*P])
					screwthread_triangle(P);

	threadDepthRadius = D_min/2;//(D_min/2)-.2
	translate([0,0,P/2])
		cylinder(r=threadDepthRadius,h=2*P,center=true);
}

// P    - screw thread pitch
// D    - screw thread major diameter
// h    - screw thread height
// step - step size in degree
module thread(P,D,h,step)
{
	for(i=[0:h/P])
		translate([0,0,i*P])
			screwthread_onerotation(P,D,step);
}

// render the assembly
{
	if(Render_WormGear)
		difference()
		{
			// Join the encoder wheel and shaft with the worm gear "screw thread"
			union()
			{
				translate([0, 0, Wheel_Height + Worm_Elevation])
					thread(Worm_Pitch, Worm_Diameter, Worm_Height, Worm_Step);
				if(Render_FDM_Support)
					translate([0,0,Wheel_Height + Worm_Elevation - 2])
						cylinder(d1=Shaft_OD, d2=screwDiamMin(Worm_Pitch, Worm_Diameter), h=1.25);
			}
			// hollow out the shaft
			cylinder(r=Shaft_ID/2, h=Shaft_Height);
		}

	// and add a "key way" to the shaft
	if(Render_D_Key)
		translate([-Shaft_ID/2,Shaft_ID/3,0])
			cube([Shaft_ID,Shaft_ID/2, Shaft_Height/2.5-.25]);
	wheel();
}

