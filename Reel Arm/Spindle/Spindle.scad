
// This 3D design and openscad source file is/are Copyright (c) 2020-2021 by Neal Horman
//
// @author		Neal Horman - nkhorman@gmail.com - Initial coding and development
// 
// @copyright	Copyright (c) 2020-2021 by Neal Horman. All Rights Reserved. 
//
// @License		Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License. 
// @license		<a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-nc-sa/4.0/88x31.png" /></a><br />These works are licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/">Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License</a>.
//
// @Version		5.0


// preview[view:south, tilt:top diagonal]

/*[Notices]*/
// This 3D design and openscad source file is/are Copyright (c) 2020-2021 by Neal Horman - nkhorman@gmail.com
Copyright = true;

/*[Reel Size]*/
// This is the tape width - in millimeters
Tape_Width = 8;//[4,8,10,12,16,24,32,44,56]

// This is the combined reel material width - in millimeters - default 3.
Reel_Width = 3;//[0:0.1:5]

/*[Fin Adjustments]*/
// Low is similar to the Quad spindle design, High is an absolute difference from the spindle length.
Fin_Height = 1;//[0:Low, 1:High]

// Add a 25 degree angle to the top edge of the fins.
Fin_25 = 1;  //[1:Yes, 0:No]

// When the "Fin Height" is "Low", you can use this to adjust the difference from the spindle length to the bottom flange surface.
Fin_Height_Difference = 10.5; //[1.5:0.1:56]

// Fin location placement - "Quad" puts the fins under the end slot cut-out, and forces "Fin Height" to "Low" for clearance purposes, "High" rotates the fins by 90 degress and allows them to crawl further towards the spindle end for additional structural support.
Fin_Rotation = 1;//[0:Quad, 1:High]

// Fin thickness - in millimeters - default 1.5
Fin_Thickness = 1.5;//[1:0.5:4]

// Fin Width - in millimeters - default 5.5
Fin_Width = 5.5;//[5.5:0.5:8]

/*[Spindle Adjustments]*/
// The spindle diameter - in millimeters - I never modeled the original Quad 12.5 diameter
Spindle_Diameter = 1;//[0:12.7, 1:13.0]

// Mounting flange diameter - in millimeters - default 25.5
Mounting_Flange_OD = 25.5; //[25.5:0.1:50]
// Mounting flange thickness - in millimeters - default 2
Mounting_Flange_Height = 2;//[2:0.1:10]

/*[Advanced]*/
// Mounting stud nut OD - in millimeters - default 9.3
Mounting_Flange_ID = 9.3; //[9.0:0.1:12]
// Mounting stud nut Height clearance - millimeters - default 2.84
Mounting_Flange_ID_Height = 2.84; //[2.84:0.1:5]

// Mounting stud length - in millimeters - default 15.5
Spindle_Shaft_Length = 15.5;//[15:0.1:30]
// Mounting stud shaft OD - in millimeters - default 8 - you probably don't want to mess with this.
Inner_Spindle_OD = 8; //[8:0.1:13]
// Mounting stud shaft ID - in millimeters - default 5.1 - you probably don't want to mess with this.
Inner_Spindle_ID = 5.1; //[5.08:0.1:10]
    

/*[Hidden]*/

function mils2mm(v) = v/39.37;

spindle(tapeWidth=Tape_Width, reelWidth=Reel_Width);

module spindleFin(location=[0, 0, 0], size=[1, 1, 1], rotation=0)
{
    x = location.x+4.6;
    y = location.y - size.y/2;
    z = location.z;
    difference() {
    rotate(rotation) translate([x,y,z]) cube(size);
    if(Fin_25)
        rotate([0,0,rotation])
            translate([x+1,y-.05,size.z+1])
                rotate([0,25,0])
                    cube([8,Fin_Thickness*1.1,3]);
    }
}

module spindleShaftSlot(location=[0, 0, 0], size=[1, 1, 1], rotation=0)
{
    x = location.x;
    y = location.y;
    z = location.z + size.x/8;
    rotate(rotation) translate([x, y, z]) rotate([0, 90, 0]) union()
    {
        offsetX = 0;
        offsetZ = 0;
        translate([0, -size.y/2, offsetZ]) cube([size.x + offsetX, size.y, size.z]);
        translate([size.x + offsetX, 0, offsetZ]) cylinder(d=size.y, h=size.z);
    }
}

module spindleShaftOuter(d, h)
{
    difference()
    {
        union()
        {
            // this is subjective / imperical (I don't know the correct math to use)... I hate it and the shape!
            tH = (d == 13 ? 1.3 : 1.5);

            // the shell
            cylinder(d=d, h=h);
            // the toroid "bubble"
            translate([0, 0, h-tH])
                scale(2.3)
                    rotate_extrude(convexity = 10)
                        translate([2, 0, 0])
                            circle(r = 1, $fn = 100);
        }
        // scrape off the top of the toroid
        translate([0, 0, h]) cylinder(d=d, h=1);
    }
}

module spindleShaft(baseOD, baseLowerH, baseUpperH, slotH)
{
    difference()
    {
        slotZ = 5;
        // outer
        spindleShaftOuter(d=baseOD, h=baseUpperH);

        // inner gap
        idH = baseUpperH;//baseUpperH - baseLowerH < slotH ? baseUpperH-slotH : baseUpperH - baseLowerH;
        idZ = baseUpperH - baseLowerH < slotH ? baseUpperH-slotH-1.15 : baseLowerH;
        translate([0, 0, idZ]) cylinder(d=baseOD-3.5, h=idH-idZ+1);

        // vertical slots around "outer" cylinder
        union()
        {
            sbsSize=[slotH, 5, 5];
            sbsLoc=[3, 0, baseUpperH];
            for(rot = [0, 120, 240])
                spindleShaftSlot(size=sbsSize, location=sbsLoc, rotation=rot+60);
        }
    }
}

module flangeText(size, h, text)
{
    linear_extrude(height=h, convexity=4)
        text(
            text, 
            size=size,
            font="Bitstream Vera Sans",
            halign="center",
            valign="center"
        );
}

// module curvedText() - as published @ https://www.thingiverse.com/thing:2419115/files
module curvedText(txt, r=10, size=10, spacing=1, valign="baseline", font) {
  a = 180 * size * spacing / (PI * r);
  for (i = [0:len(txt)-1])
    rotate([0,0,-(i+0.5)*a]) 
    translate([0,r])
        text(txt[i], size=2.3, halign="center", valign=valign, $fn=32, font=font);
}

module underText(od, id, txt, txtSize, h)
{
    r = od/2;
    R = (od/2)*id;
    x = (R-r)/4;
    txtPadding = x-txtSize/2;
    
    spacing = .85;
    font="Bitstream Vera Sans";

    rotate([180,0,0])
    linear_extrude(height=h, convexity=4)
    curvedText(txt
            , r=r+x+txtPadding
            , size=txtSize
            , spacing=spacing
            , font=font
            );
}

module spindle(tapeWidth, reelWidth, $fn=100)
{
    mountingFlangeH = Mounting_Flange_Height;//2; //.079
    spindleFingerLength = 5.3;
    
    spindleLength = tapeWidth + reelWidth + mountingFlangeH + spindleFingerLength;
    echo(str("Spindle Length = ", spindleLength));
    
    mountingFlangeOD = Mounting_Flange_OD;//25.5; // 1"
    
    mountingFlangeID = Mounting_Flange_ID;//9.3; // 9.52=.375 9=.354
    mountingFlangeIDH = Mounting_Flange_ID_Height;//2.84; // .112"
    
    spindleShaftLength = Spindle_Shaft_Length;//15.5;
    spindleShaftOD = (Spindle_Diameter == 0 ? 12.7 : 13);
    
    innerSpindleH = spindleShaftLength;
    innerSpindleOD = Inner_Spindle_OD;//8; // .315
    innerSpindleID = Inner_Spindle_ID;//5.1; //5.08=.200 4.83=.190"
    
    finHeight = (Fin_Height == 0 || Fin_Rotation == 0)
        ? spindleLength - Fin_Height_Difference
        : (tapeWidth + reelWidth + mountingFlangeH)
        ;

    finSize = [Fin_Width, Fin_Thickness, finHeight];

    difference()
    {
        difference() // body
        {
            union()
            {
                // base flange
                cylinder(d=mountingFlangeOD, h=mountingFlangeH);

                // top - side text
                for(rot = [0, 120, 240])
                    rotate(rot+(Fin_Rotation == 1 ? 90 : 30))
                        translate([0, mountingFlangeOD*.36, 1.5])
                            flangeText(size=5, h=Mounting_Flange_Height-1, text=str(tapeWidth));

                // base spindle outer diameter
                spindleShaft(
                    baseOD = spindleShaftOD
                    , baseLowerH = innerSpindleH
                    , baseUpperH = spindleLength
                    , slotH = mils2mm(350)
                    );

                // spindle mounting shaft - outer
                cylinder(d=innerSpindleOD, h=innerSpindleH);

                // fins
                for(rot=[0,120,240])
                    spindleFin(size=finSize, rotation=rot+(Fin_Rotation == 1 ? 0 : 60));
            }
            // spindle mounting shaft - inner
            cylinder(d=innerSpindleID, h=innerSpindleH+1);
        }
        // flange mounting spindle nut cavity
        translate([0,0,-.01]) cylinder(d=mountingFlangeID, h=mountingFlangeIDH);

        // flange recess / under-side text cavity
		if(Copyright)
	        translate([0,0,-.002]) cylinder(d=mountingFlangeOD*.90, h=mountingFlangeH*.3);
    }

    // under-side text
	if(Copyright)
	{
		flangeCavityOD = mountingFlangeOD*.90;
		translate([0,0,1])
		{
			underText(od=flangeCavityOD, id=.7, txt="Design (c) by Neal Horman 2021", txtSize=2, h=.8);
			underText(od=flangeCavityOD*.7, id=.7, txt="github.com/quadopenxyz", txtSize=1.8, h=.8);
		}
	}
}
