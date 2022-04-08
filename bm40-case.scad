include <roundedCube.scad>
include <Round-Anything/polyround.scad>
include <variables.scad>
use <bm40-pcb-mock.scad>

split=false;
top=false;
bottom=true;

$fa = 1;
$fs = 0.4;

padding=0;
battery_pack=[180, 35];
angle=4;
pcb_padding=[0.5, 0.5];
plate_dimensions=[
	button_spacing * 12 + pcb_padding.x*2,
	button_spacing * 4+ pcb_padding.y *2,
	plate_thickness
];
thickness=3;
plate_offset=0;
back_angling_offset=5;
usb_hole_padding=1.5;
top_case_height=plate_top_pcb_offset + pcb.z + plate_offset + thickness/2 + 0.5;

dimensions = [
	plate_dimensions.x + thickness,
	plate_dimensions.y + thickness,
	top_case_height + back_angling_offset + thickness
];

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
					translate(pcb_padding) translate(screw) cylinder(plate_top_pcb_offset - plate_thickness + 1, 3.5, 3.5, center = true);
					// #translate([-5, -5, pcb.z]) translate(screw) cube([10, 10, pcb.z]);
				}
			}
		}
		translate([button_padding + pcb_padding.x, button_padding + pcb_padding.y, 0]) grid();

		for(screw = screw_positions) {
			translate([pcb_padding.x, pcb_padding.y, 1]) translate(screw) cylinder(plate_top_pcb_offset + 1, 1.5, 1.5, center = false);
		}
	}
}

module usb_hole() {
	width = usb_socket.x + usb_hole_padding * 2;
	translate([-width / 2 + usb_hole_padding, 0, 0]) union() {
		roundedCube([width, 20, usb_socket.z + usb_hole_padding], 1.3, true, true, true);
	}
}

module logo(withName) {
	union() {
		translate([-4.5, 0, 5.5125])
			rotate([-90, 0, 0])
			linear_extrude(height = 1, center = true)
			mirror([1, 0, 0])
			resize([9, 11.25, 0])
			import("dayone-logo.svg", center = true);
		if(withName) {
			translate([-11, 0, 8.5])
			rotate([-90, 0, 0])
			linear_extrude(height = 1, center = true)
			mirror([1, 0, 0])
			text("D1", size=5, font="Montserrat:style=bold italic");
		}
	}
}

module exterior() {
	height=dimensions.z;
	union() {
		difference() {
			linear_extrude(height) {
				offset(r=thickness) {
					square([plate_dimensions[0], plate_dimensions[1]]);
				}
			}
			translate([0, 0 ,-1]) linear_extrude(20) {
				square([plate_dimensions[0], plate_dimensions[1]]);
			}
			translate([pcb.x - 5, -thickness + 0.2, 2.5]) logo(withName=true);
			translate([usb_position - usb_hole_padding / 2, -10, plate_top_pcb_offset + pcb.z + plate_offset - usb_hole_padding/2]) usb_hole();
			back_angling();
		}
		translate([-1, -1, height - 3.8]) rotate([-5, 0, 0]) feet(3, 1, 1);
		translate([dimensions.x - thickness + 1, -1, height - 3.8]) mirror([1, 0, 0]) rotate([-5, 0, 0]) feet(3, 1, 1);
	}
}

module top_case() {
	union() {
		render() translate([0, 0, plate_offset]) plate();
		exterior();
	}
}


module case() {
	top_case();
}

module screw_mount() {
	union() {
		translate([0, 0, -1]) cylinder(bottom_case_height + 2, 1.2, 1.2);
		translate([0, 0, bottom_case_height - 1]) cylinder(1.6, 1, 3);
	}
}

module feet(height, margin_right, margin_top) {
	difference() {
		linear_extrude(height) {
			polygon(polyRound([
				[0,    0,  0],
				[0, 11 + margin_top,  0],
				[26 + margin_right,  11 + margin_top,  2],
				[26 + margin_right,  0,  0]
			], 20));
		}
		translate([3, 2, 2])roundedCube([22.2, 8.2, 1], 4);
		// translate([6, 6, 1]) cylinder(2, 4.5, 4.5);
	}
}


module back_angling() {
	translate([-10, -10, dimensions.z ]) rotate([-angle, 0, 0]) cube([dimensions.x + 20, dimensions.y + 20, 20]);
}

module splitter() {
	translate([-3, -3, -1]) union() {
		cube([plate_dimensions[0] / 2 - button_spacing + 3.25, plate_dimensions[1] + 10, 50]);
		translate([plate_dimensions[0] / 2 - button_spacing + 3.25 , button_spacing + 3, 0]) cube([38, 38, 50]);
	}
}

module splitted_case() {
	translate([-plate_dimensions[0] / 2 + 20, 0, 0]) difference() {
		case();
		splitter();
	}
	translate([0, plate_dimensions[1] + 10, 0]) intersection() {
		case();
		splitter();
	}
}


if(split)
	splitted_case();
else
	case();

*render() translate([button_padding / 2, button_padding / 2, plate_top_pcb_offset + plate_offset]) pcb_mock();
