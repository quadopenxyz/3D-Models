// https://www.thingiverse.com/thing:156076/files

/*[Parts to Render]*/
Render_Slits = true;
Render_Shaft = true;
Render_Shaft_Extrude = true;
Render_WormGear = true;

Worm_Pitch = 1.66;//1.75;//2;//1.5;
Worm_Diameter = 9.6;
Worm_Height = 14;
Worm_Step = 10;
Worm_Offset = 1;

shaftDiameter = 2.1;//2.3188; //2.4188;//2.4125;//2.425; // shaft ID
shaftOD = 4.75;
wheelDiameter = 17;

shaftHeight = 25;
shaftBevel = 0.3;

wheelHeigh = 1.3;
wheelGrooveDepth = 0.0;

encoderOD = 17;
encoderID = 9.5;

encoderSlitCount = 20;
encoderSlitType = 0;//[0:Rectangle, 1:Wedge, 2:Tilted Rectangle, 3:Tilted Wedge, 4:Rounded]

/*[Hidden]*/
$fn=200;

encoderSlitWidth = (360/encoderSlitCount) / encoderOD;//2.35;

shaftMargin = (shaftOD - shaftDiameter)/2; // shaft radius
encoderInnerRadius = encoderID/2;
encoderOuterRadius = encoderOD/2;
shaftR = shaftDiameter/2;
wheelR = wheelDiameter/2;

encoderSlitLength = encoderOuterRadius-encoderInnerRadius;

pollyPoints = [
	[shaftR+shaftBevel,0],
	[wheelR,0],
	[wheelR-wheelGrooveDepth,wheelHeigh/2],
	[wheelR,wheelHeigh],
	[shaftR+shaftMargin,wheelHeigh],
	[shaftR+shaftMargin,shaftHeight],
	[shaftR+shaftBevel,shaftHeight],
	[shaftR,shaftHeight-shaftBevel],
	[shaftR,shaftBevel],
	];

module DrawSlit()
{
  if (encoderSlitType == 0)
  {
    cube(size = [encoderSlitWidth, encoderSlitLength, wheelHeigh+.1], center = true);
  }
  else if (encoderSlitType == 1)
  {
    translate([0, -encoderSlitLength / 2, 0 ])
		hull()
		{
			cube([encoderSlitWidth * .7, 0.01, wheelHeigh+.1], center = true);
			translate([0, encoderSlitLength, 0])
				cube([encoderSlitWidth * 1.3, 0.01, wheelHeigh+.1], center = true);
		}
  }
  else if (encoderSlitType == 2)
  {
    rotate(-15, [0, 0, 1])
      translate([0, 0.2, 0])
        cube(size = [encoderSlitWidth, encoderSlitLength * 1.2, wheelHeigh+.1], center = true);
  }
  else if (encoderSlitType == 3)
  {
    rotate(-15, [0, 0, 1])
		translate([0, (-encoderSlitLength / 2) - 0.2, 0 ])
			hull()
			{
				cube([encoderSlitWidth * .7, 0.01, wheelHeigh+.1], center = true);
				translate([0, encoderSlitLength * 1.3, 0])
					cube([encoderSlitWidth * 1.3, 0.01, wheelHeigh+.1], center = true);
			}
  }
  else if (encoderSlitType == 4)
  {
    translate([0,wheelHeigh/4,0]) rotate([0,0,90]) hull()
    {
      translate([encoderSlitLength/3.141,0,0])
        cylinder(d=encoderSlitWidth, h=wheelHeigh+.1, center = true);
      translate([-encoderSlitLength/3.141,0,0])
        cylinder(d=encoderSlitWidth, h=wheelHeigh+.1, center = true);
    }
  }
}

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
			union()
			{
				for(i=[0:encoderSlitCount-1])
				{
					rotate(a = [0,0,(360/encoderSlitCount)*i])
					{
						translate(v=[0, encoderInnerRadius+(encoderSlitLength/2), -.05])
						{
							translate ([0, 0, (wheelHeigh/2)+.05]) 
								DrawSlit();
						}
					}
				}
			}
		}
	}
}


// https://www.thingiverse.com/thing:31363/files

// Metric Screw Thread Library
// by Maximilian Karl <karlma@in.tum.de> (2012)
// 
//
// only use module thread(P,D,h,step)
// with the parameters:
// P    - screw thread pitch
// D    - screw thread major diameter
// h    - screw thread height
// step - step size in degree
// 

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

	translate([0,0,P/2])
		//cylinder(r=D_min/2,h=2*P,$fn=360/step,center=true);
		cylinder(r=D_min/2,h=2*P,center=true);
}

module thread(P,D,h,step)
{
	for(i=[0:h/P])
		translate([0,0,i*P])
			screwthread_onerotation(P,D,step);
}

{
	if(Render_WormGear)
		difference()
		{
			union()
			{
				translate([0, 0, wheelHeigh + Worm_Offset + 2])
					thread(Worm_Pitch, Worm_Diameter, Worm_Height, Worm_Step);
				translate([0,0,wheelHeigh + Worm_Offset])
					cylinder(d1=shaftOD, d2=screwDiamMin(Worm_Pitch, Worm_Diameter), h=1.25);
			}
			cylinder(r=shaftDiameter/2, h=shaftHeight);
		}
	// D key
	translate([-shaftDiameter/2,shaftDiameter/3,0])
		cube([shaftDiameter,shaftDiameter/2, shaftHeight/2.5-.25]);
	wheel();
}

