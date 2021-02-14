
// preview[view:south, tilt:top diagonal]

// In MM
Tape_Width = 32;//[32,48,56]
// In MM
Tape_Depth = 8;//[2:1:8]
// In Mils
Vertial_Offset = 330;
// In Mils
Plate_Width = 900;

/*[Hidden]*/

tape_w = mm2mils(Tape_Width);
tape_d = mm2mils(Tape_Depth);
spring_w = 200;
spring_h = Vertial_Offset;//330;//350;
springStud_d = 125;

plate_h = (spring_h/2) + tape_d;
plate_w = Plate_Width;//900;
plate_thick = 62;

stud1_d = 272;
stud1_h = 140;

stud2_d = 245;
//stud2_h = (tape_w-spring_w)/2 - plate_thick;
stud2_h = (tape_w-spring_w-plate_thick)/2;

stud_hole = 106;
stud_hole_through = 125;
stud_w = 500;//766-(stud1_d/2) - stud1_d/2;

/*[Hidden]*/
$fn=100;

function mils2mm(v) = v/39.37;
function mm2mils(v) = v*39.37;

// the outside edge mounting assembly
translate([-15, 0, mils2mm(stud1_h)]) rotate([0,-90,0])
//translate([-15,0,0])
	p1();

// the inside edge retaining clip
translate([0, 0, mils2mm(plate_thick)]) rotate([0, 90, 0])
	p2();

module p2()
{
	plate_wp2 = plate_w + springStud_d;
	ofs = (plate_w-stud_w)/2;

	difference()
	{
		translate([0, -mils2mm((plate_wp2-plate_w)/2), 0])
			cube([mils2mm(plate_thick), mils2mm(plate_wp2), mils2mm(stud2_d+15)]);
		
		for(y=[0,stud_w])
			translate([0, mils2mm(y + ofs), mils2mm((stud2_d+15)/2)])
				rotate([0, 90 ,0])
					cylinder(d=mils2mm(stud_hole_through), h=mils2mm(plate_thick));
	}
	
	for(y=[0,plate_wp2-springStud_d])
		translate([-mils2mm(spring_w * 1.25), mils2mm(y), mils2mm(springStud_d)/2])
			rotate([0, 90, 0])
				cylinder(d=mils2mm(springStud_d), h=mils2mm(spring_w * 1.25));
}

module stud(d, h ,s, d2=0, h2=0)
{
	difference()
	{
		cylinder(d=d, h=h);
		cylinder(d=s, h=h);
	}
	if(d2 > 0 && h2 >0)
		cylinder(d=d2, h=h2);
}

module p1()
{
	cube([mils2mm(plate_thick), mils2mm(plate_w), mils2mm(plate_h)]);
	
	ofs = (plate_w-stud_w)/2;

	// plate side
	for(y=[0,stud_w])
		translate([-mils2mm(stud1_h), mils2mm(y + ofs), mils2mm(plate_h-stud1_d/2)])
			rotate([0, 90 ,0])
				stud(d=mils2mm(stud1_d), h=mils2mm(stud1_h), s=mils2mm(stud_hole));

	// support side
	for(y=[0,stud_w])
		//rotate([0, 180, 0])
			translate([mils2mm(plate_thick), mils2mm(y + ofs), mils2mm(stud2_d+15)/2])
				rotate([0, 90 ,0])
					stud(d=mils2mm(stud2_d), h=mils2mm(stud2_h), s=mils2mm(stud_hole)
						, d2=mils2mm(stud2_d+15), h2=mils2mm(stud2_h-spring_w)
						);
}
