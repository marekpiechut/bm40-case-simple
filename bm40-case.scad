include <roundedCube.scad>
include <Round-Anything/polyround.scad>
include <variables.scad>
use <bm40-pcb-mock.scad>

split=false;
left_only=false;
right_only=false;

$fa = 1;
$fs = 0.4;

padding=0;
plate_dimensions=[button_spacing * 12, button_spacing * 4, plate_thickness];
back_angling_offset=5;
pcb_bottom_offset=1;
usb_hole_padding=1;


module button(small_notch) {
	notch_offset = small_notch ? 0.5 : 1;
	union() {
		cube([14, 14, 10]);
		translate([-notch_offset, 1, 0]) cube([2, 3.2, 10]);
		translate([-notch_offset, 10, 0]) cube([2, 3.2, 10]);
		translate([12.2 + notch_offset, 1, 0]) cube([2, 3.2, 10]);
		translate([12.2 + notch_offset, 10, 0]) cube([2, 3.2, 10]);
	}
}

module button_stabilizer_hole(inverted) {
	stablilizer_space_pos = inverted ? [1, -3.5, 5.5] : [8, 17.5, 5.5];
	stabilizer_space_rotation = inverted ? [0, 90, 0] : [0, 90, 180];
	roundedCube([8, 15, 10]);
}

module button_stabilizer_space(inverted) {
	width = 33;
	stablilizer_space_pos = inverted ? [0, -3.5, plate_thickness + 0.5] : [0, button_spacing - 8, plate_thickness + 0.5];
	translate(stablilizer_space_pos)
		cube([width, 6, 10]);
}

module button_2u(inverted) {
	union() {
		translate([button_spacing / 2, 0, 0]) button(true);
		translate([0, -0.5, 0]) button_stabilizer_hole();
		translate([33 - 7 - 1, -0.5, 0]) button_stabilizer_hole();
		button_stabilizer_space(inverted);
	}
}

module buttons(rows, cols) {
	for (i=[0:1:cols - 1]) {
		for (j=[0:1:rows - 1]) {
			translate([i*button_spacing,j*button_spacing, -2]) button();
		}
	}
}

module grid() {
	buttons(3, 12);
	translate([0, button_spacing * 3, 0]) buttons(1, 5);
	translate([button_spacing * 7, button_spacing * 3, 0]) buttons(1, 5);
	translate([button_spacing * 5, button_spacing * 3, -2]) button_2u(true);
}


module plate() {
	difference() {
		union() {
			cube(plate_dimensions);
			translate([padding, padding, plate_top_pcb_offset - 1.5]) {
				for(screw = screw_positions) {
					translate(screw) cylinder(plate_top_pcb_offset - plate_thickness + 1, 3.5, 3.5, center = true);
				}
			}
		}
		translate([button_padding, button_padding, 0]) grid();

		for(screw = screw_positions) {
			translate([padding, padding, 1]) translate(screw) cylinder(plate_top_pcb_offset + 1, 1.5, 1.5, center = false);
		}
	}
}

module usb_hole() {
	width = usb_socket.x + usb_hole_padding + 4;
	translate([-width / 2 + 1, 0, 0]) union() {
		//TODO: Remove flat side and make hole smaller after removing bump from pcb
		roundedCube([width, 20, usb_socket.z + usb_hole_padding + pcb.z], 1.3, false, true, false);
		cube([usb_socket.x + usb_hole_padding + 4, 20, 2]);
	}
}

module logo() {
	union() {
		translate([-4.5, 0, 5.5125])
			rotate([-90, 0, 0])
			linear_extrude(height = 1, center = true)
			mirror([1, 0, 0])
			resize([9, 11.25, 0])
			import("dayone-logo.svg", center = true);
		translate([-11, 0, 8.5])
			rotate([-90, 0, 0])
			linear_extrude(height = 1, center = true)
			mirror([1, 0, 0])
			text("D1", size=5, font="Montserrat:style=bold italic");
	}
}

module exterior() {
	height=plate_top_pcb_offset + 2.6	 + pcb_bottom_offset + back_angling_offset;
	union() {
		difference() {
			linear_extrude(height) {
				offset(r=2) {
					square([plate_dimensions[0], plate_dimensions[1]]);
				}
			}
			translate([0, 0 ,-1]) linear_extrude(20) {
				square([plate_dimensions[0], plate_dimensions[1]]);
			}
			translate([usb_position, -10, plate_top_pcb_offset]) usb_hole();
			translate([pcb.x - 5, -1.8, 1.5]) logo();
			back_angling();
		}
		difference() {
			union() {
				translate([-1, -1, height - 2.45]) rotate([-3, 0, 0]) feet(2.5, 1, 1);
				translate([pcb.x + padding + 3, -1, height - 2.45]) mirror([1, 0, 0]) rotate([-3, 0, 0]) feet(2.5, 1, 1);
			}
			translate([-10, -5, height]) cube([pcb.x + 100, 10, 10]);
		}
	}
}

module feet(height, margin_right, margin_top) {
	difference() {
		linear_extrude(height) {
			polygon(polyRound([
				[0,		0,	0],
				[0, 	11 + margin_top,	0],
				[12 + margin_right,	11 + margin_top,	2],
				[12 + margin_right,	0,	0]
			], 20));
		}
		translate([6, 6, 1]) cylinder(2, 4.5, 4.5);
	}
}

module case() {
	union() {
		plate();
		exterior();
	}
}

module back_angling() {
	translate([400, 0, plate_top_pcb_offset + 2.6 + pcb_bottom_offset + back_angling_offset]) rotate([270, 0, 90]) linear_extrude(500) {
		polygon([
			[0, 0], [plate_dimensions[1] + 2, 0], [plate_dimensions[1] + 2, back_angling_offset]
		]);
	}
}

module splitter() {
	translate([-3, -3, -1]) union() {
		cube([plate_dimensions[0] / 2 - button_spacing + 3.25, plate_dimensions[1] + 10, 50]);
		translate([plate_dimensions[0] / 2 - button_spacing + 3.25 , button_spacing + 3, 0]) cube([38, 38, 50]);
	}
}

module splitted_case() {
	if(!left_only) {
		translate([-plate_dimensions[0] / 2 + 20, 0, 0]) difference() {
			case();
			splitter();
		}
	}
	if(!right_only) {
		translate([0, plate_dimensions[1] + 10, 0]) intersection() {
			case();
			splitter();
		}
	}
}


if(split)
	splitted_case();
else
	case();

// translate([button_padding / 2, button_padding / 2, plate_top_pcb_offset]) pcb_mock();
