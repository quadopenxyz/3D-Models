
// preview[view:south, tilt:top diagonal]

/*[Parts to Render]*/
Render_Bottom = true;
Render_Back = true;
Render_Back_Horizontal = false;

/*[Dimensions]*/

slots = 6;
slot_interval = 400;

bay_w = slot_interval * slots + 400;
bay_h = 4000;
bay_depth = 7510;//7530;
bay_thick = 125;

slot_w = 104;
slot_ofs = 250;
slot_z = 200;

slot_pocket_w = 1200;
slot_pocket_rail_w = 200;

bay_pcb_thick = 63;
bay_pcb_h = 1500;
bay_pcb_z = 265;
bay_pcb_setback = 150;

feeder_connector_w = 310;
feeder_connector_h = 1000;
feeder_connector_Z = 500;

pin_hole_d = 150;
pin_hole_h = 230; // obround vertical height for pin_hole_d 
pin_hole_depth = 100;
pin_hole_y = 225;
pin_hole_z = 3300;

dimple_d = pin_hole_d;
dimple_depth = dimple_d/2;
dimple_y = pin_hole_y;
dimple_z = 135;//125;

join_stud_d = 125 * 1.25;
join_stud_h = bay_thick + bay_pcb_setback/2;//join_stud_d;


/*[Hidden]*/
$fn=100;

function mils2mm(v) = v/39.37;
function mm2mils(v) = v*39.37;

bay();

module stud(d, h)
{
	h1 = h * .80;
	h2 = h * .20;
	cylinder(d=d, h=h1);
	// chamfer
	translate([0,0,h1])
		cylinder(d1=d, d2=d*.8, h=h2);
}

module cylinder2(d1, h1, d2, h2)
{
	cylinder(d=d1, h=h1);
	cylinder(d=d2, h=h2);
}

module screwHoleClearance(screw, h)
{
	cylinder2(d1=mils2mm(screw[1]), h1=mils2mm(h), d2=mils2mm(screw[2]), h2=mils2mm(screw[3]));
}

module obroundHole(d1,d2,h)
{
    union()
    {
        translate([-d1/4, -d2/2, 0]) cube([d1/2, d2, h]);
        translate([d1/4, 0, 0]) cylinder(d=d2, h=h);
        translate([-d1/4, 0, 0]) cylinder(d=d2, h=h);
    }
}

632_hole = [126, 140, 225, 90]; // [Thread diameter, Thread clearance diameter, Head clearance diameter, Head Depth]
632_hole_depth = join_stud_h;

num4_hole_middle_offset = 125/2;
num4_hole = [115, 140, 225, 90]; // [Thread diameter, Thread clearance diameter, Head clearance diameter, Head Depth]
num4_hole_depth = 390;
num4_hole_offsets = [150, bay_w-150, bay_w/2 - num4_hole_middle_offset];

module bottom()
{
	difference()
	{
		// plate
		cube([mils2mm(bay_depth), mils2mm(bay_w), mils2mm(bay_thick + slot_z)]);
		
		// rough approximation of the bottom of a feeder
		//%translate([0,-5,0]) cube([mils2mm(6150), 10, mils2mm(4120)]);
		//%translate([0,2,0]) cube([mils2mm(7350), 10, mils2mm(4120)]);
		//%translate([0,2,0]) cube([mils2mm(7400), 10, 5]);
		
		// cavities
		union()
		{
			// slots
			for(y=[0:slots-1])
				translate([0, mils2mm(y*slot_interval + slot_ofs + (slot_w/2)), mils2mm(bay_thick)])
					cube([mils2mm(bay_depth - slot_pocket_w - slot_pocket_rail_w), mils2mm(slot_w), mils2mm(slot_z)]);

			// pocket cavity
			translate([mils2mm(bay_depth - slot_pocket_w - slot_pocket_rail_w), 0, mils2mm(bay_thick)])
				cube([mils2mm(slot_pocket_w), mils2mm(bay_w)+2, mils2mm(slot_z)]);
			// latch cavity
			translate([mils2mm(bay_depth - slot_pocket_rail_w), mils2mm(bay_w), mils2mm(bay_thick)])
				rotate([90,0,0])
					linear_extrude(height =mils2mm(bay_w))
						polygon([[0,0],[mils2mm(80),0],[0,mils2mm(slot_z)]]);
		
			// screw holes
			for(y=num4_hole_offsets)
				translate([0, mils2mm(y), mils2mm(bay_thick + slot_z)/2])
					rotate([0, 90, 0])
						cylinder(d=mils2mm(num4_hole[0]), h=mils2mm(num4_hole_depth));
		}
	}
}

module backUpperPocket(x, y, z)
{
	t = mils2mm(125);
	difference()
	{
		// the window
		translate([0,0,0]) cube([x, y, z]);
		
		// the cross hair
		llur = [ [0,0], [t/2,0], [z,y-t/2], [z,y], [z-t/2,y], [0,t/2], [0,0] ]; // lower left to upper right
		ullr = [ [z,0], [z,t/2], [t/2,y], [0,y], [0,y-t/2], [z-t/2,0], [z,0] ]; // upper left to lower right
		translate([x,0,0])
			rotate([0,-90,0])
				linear_extrude(height=x)
				{
					polygon(llur);
					polygon(ullr);
				}
	}
}

module back()
{
	translate([-mils2mm(bay_thick + bay_pcb_setback), 0, 0])
		difference()
		{
			thick_pcb_setback = bay_pcb_setback + bay_pcb_thick;
			thick_all = bay_thick + thick_pcb_setback;
			// back metal
			cube([mils2mm(thick_all), mils2mm(bay_w), mils2mm(bay_h)]);
			
			union()
			{
				///*
				// upper pocket
				translate([0, mils2mm(250), mils2mm(bay_thick + slot_z + 1850)])
					backUpperPocket(x=mils2mm(thick_all), y=mils2mm(bay_w-500), z=mils2mm(1000*1.25));
				//*/
				// pcb pocket
				translate([mils2mm(bay_thick), -.5, mils2mm(bay_thick + slot_z + bay_pcb_z)])
					cube([mils2mm(thick_pcb_setback), mils2mm(bay_w)+1, mils2mm(bay_pcb_h)]);
				// pcb clamp / mount screw holes
				for(z=[0, bay_pcb_h-250]) // backside clearance holes
					for(y=[250, bay_w-250])
						translate([0, mils2mm(y), mils2mm(bay_thick + slot_z + feeder_connector_Z - 632_hole[0] + z)])
							rotate([0, 90, 0])
								cylinder(d=mils2mm(632_hole[0]), h=mils2mm(bay_thick));

				x = thick_all;
				z = bay_thick + slot_z;
				for(i=[0:slots-1])
				{
					y = i*slot_interval + slot_ofs;
					
					// uper aligment pin pocket
					translate([mils2mm(x -pin_hole_depth), mils2mm(y + slot_w), mils2mm(z + pin_hole_z)])
						rotate([0, 90, 0])
							obroundHole(d1=mils2mm(pin_hole_h), d2=mils2mm(pin_hole_d), h=mils2mm(pin_hole_depth));
					
					// lower alignment recess
					translate([mils2mm(x-dimple_depth), mils2mm(y + slot_w), mils2mm(z + dimple_z)])
						rotate([0,90,0])
							cylinder(d=mils2mm(dimple_d), h=mils2mm(dimple_depth));//sphere(mils2mm(dimple_d/2));
				}

				// screw holes
				for(y=num4_hole_offsets)
					translate([0, mils2mm(y), mils2mm(bay_thick + slot_z)/2])
						rotate([0, 90, 0])
							screwHoleClearance(screw=num4_hole, h=thick_all);
			}
		}

/*
		// pcb examplar
		color("green") translate([-mils2mm(bay_pcb_setback), 0, mils2mm(bay_thick + slot_z + bay_pcb_z)])
			cube([mils2mm(bay_pcb_thick), mils2mm(bay_w), mils2mm(bay_pcb_h)]);
		// pogo pin examplar
		translate([mils2mm(join_stud_d)/2 - mils2mm(bay_pcb_setback), mils2mm(join_stud_d), mils2mm(bay_pcb_z + slot_z + bay_thick + join_stud_d)])
			rotate([0,90,0])
				cylinder(d=mils2mm(join_stud_d), h=mils2mm(bay_pcb_setback));
*/		
}

module bay()
{
	if(Render_Bottom)
		bottom();
	if(Render_Back && Render_Back_Horizontal)
		rotate([0,-90,0]) translate([mils2mm(bay_thick + slot_z - bay_pcb_thick), 0, 10]) back();
	//translate([-mils2mm(bay_pcb_thick), 0, 0]) back();
	if(Render_Back && !Render_Back_Horizontal)
		translate([-20, 0, 0]) back();
/*	
	a = bay_thick + slot_z + bay_pcb_z;
	b = bay_thick + slot_z;
	ar = [ [0,0], [0,mils2mm(a)], [mils2mm(b), mils2mm(a)], [mils2mm(a), mils2mm(b)], [mils2mm(a),0], [0,0] ];
	for(y=[0,mils2mm(bay_w)+1])
		translate([-mils2mm(b),y,0])
			rotate([90,0,0])
				linear_extrude(height=1)
					polygon(ar);
*/
}

