include <roundedCube.scad>
include <Round-Anything/polyround.scad>
include <variables.scad>
include <keyboard-grid.scad>
use <bm40-pcb-mock.scad>

split=false;
top=true;
bottom=true;
mit_layout=false;
thick=true;

$fa = 1;
$fs = 0.4;

padding=0;
battery_pack=[180, 35];
angle=4;
pcb_padding=[0.5, 0.5];
plate_dimensions=[
	button_spacing * 12 + pcb_padding.x*2,
	button_spacing * 4+ pcb_padding.y *2,
	thick ? plate_top_pcb_offset : plate_thickness
];
thickness=4;
plate_offset=0;
plate_spacing=0.5;
back_angling_offset=5;
usb_hole_padding=1.5;
bottom_pcb_offset=3;
top_case_height=plate_top_pcb_offset + pcb.z + plate_offset + thickness/2;
bottom_case_height= top_case_height + bottom_pcb_offset + thickness / 2;
dimensions = [
	plate_dimensions.x + thickness,
	plate_dimensions.y + thickness,
	bottom_case_height
];

module plate() {
	translate([plate_spacing, plate_spacing]) difference() {
		cube([plate_dimensions.x - plate_spacing * 2, plate_dimensions.y - plate_spacing * 2, plate_dimensions.z]);
		translate([button_padding, button_padding, 0]) buttons_grid();

		for(screw = screw_positions) {
			translate(screw) screw_mount();
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

module buttons_grid() {
	if(mit_layout) {
		buttons(3, 12);
		translate([0, button_spacing * 3, 0]) buttons(1, 5);
		translate([button_spacing * 7, button_spacing * 3, 0]) buttons(1, 5);
		translate([button_spacing * 5, button_spacing * 3, -2]) button_2u(true);
	} else {
		buttons(4, 12);
	}
}

module exterior() {
	height=top_case_height;
	difference() {
		linear_extrude(height) {
			offset(r=thickness) {
				square([plate_dimensions[0], plate_dimensions[1]]);
			}
		}
		translate([0, 0 ,-1]) linear_extrude(20) {
			square([plate_dimensions[0], plate_dimensions[1]]);
		}
		translate([pcb.x - 5, -thickness + 0.2, 1.5]) scale([0.5, 1, 0.5]) logo(withName=true);
		// back_angling();
	}
}

module top_case() {
	union() {
		render() translate([0, 0, plate_offset]) plate();
		// exterior();
	}
}

module case() {
	difference() {
		union() {
			if(top) {
				top_case();
			}

			if(bottom) {
				difference() {
					translate([0, 0, dimensions.z - bottom_case_height - thickness / 2]) bottom_case();
					translate([usb_position - usb_hole_padding / 2, -10, plate_top_pcb_offset + pcb.z + plate_offset]) usb_hole();
				}
			}
		}
	}
}

module screw_mount() {
	if(thick) {
		union() {
			translate([0, 0, -1]) cylinder(plate_dimensions.z + 2, 1.2, 1.2);
			translate([0, 0, -0.8]) cylinder(1.8, 3, 1);
		}
	} else {
		cylinder(plate_thickness + 2, 1.8, 1.8, center = false);
	}
}

module bottom_case() {
	difference() {
		union() {
			difference() {
				linear_extrude(bottom_case_height) {
					offset(r=thickness) {
						square([plate_dimensions[0], plate_dimensions[1]]);
					}
				}
				translate([0, 0, -2]) cube([plate_dimensions.x, plate_dimensions.y, bottom_case_height]);
			}
			for(screw = screw_positions) {
				translate([pcb_padding.x, pcb_padding.y, bottom_case_height - 2 - bottom_pcb_offset]) translate(screw) cylinder(4, 3.5, 3.5);
			}
			translate([dimensions.x / 2 - battery_pack.x / 2 - thickness / 2, 0, bottom_case_height]) {
				battery_space();
			}
		}
		for(screw = screw_positions) {
			translate([pcb_padding.x, pcb_padding.y, bottom_case_height - 2 - bottom_pcb_offset - 1])
			translate(screw)
			cylinder(bottom_pcb_offset + 2, 1.5, 1.5, center = false);
		}
		translate([dimensions.x / 2 - battery_pack.x / 2 - thickness / 2, 0, bottom_case_height]) {
			battery_hole();
		}
		translate([0, dimensions.y - 8.2 - thickness, bottom_case_height - 0.5]) feet();
		translate([dimensions.x - 22.2 - thickness, dimensions.y - thickness - 8.2, bottom_case_height - 0.5]) feet();
		translate([reset_button.x + pcb_padding.y, reset_button.y + pcb_padding.y, 1]) cylinder(thickness + 2, 1, 1);
	}
}

module feet() {
	roundedCube([22.2, 8.2, 1], 4);
}


pre_battery_space = dimensions.y - battery_pack.y - thickness;
battery_y1=tan(angle) * pre_battery_space;
battery_y2=tan(angle) * (dimensions.y - thickness);
echo(str("Angles, battery_y1: ", battery_y1, " battery_y2: ", battery_y2, " pre: ", pre_battery_space));
module battery_space() {
	translate([battery_pack.x, battery_pack.y, 0])  {
		difference() {
			rotate([90, 0, -90]) {
				linear_extrude(battery_pack.x) polygon([[0, 0] ,[battery_pack.y, 0], [battery_pack.y, battery_y2], [0, battery_y1]]);
			}
			translate([- 22.2 - thickness, - battery_pack.y + thickness, battery_y2 - 1]) feet();
			translate([- battery_pack.x + thickness, - battery_pack.y + thickness, battery_y2 - 1]) feet();
			translate([-battery_pack.x / 2 + 4.5, - battery_pack.y + 6, battery_y2 - 0.5]) rotate([-90 - angle, 0, 0]) logo();
		}
	}
}

module battery_hole() {
	translate([battery_pack.x - thickness, battery_pack.y, -2]) rotate([90, 0, -90]) {
		linear_extrude(battery_pack.x - thickness * 2) polygon([[thickness, 0] ,[battery_pack.y - thickness, 0], [battery_pack.y - 2, battery_y2], [2, battery_y1]]);
	}
}

module back_angling() {
	translate([-10, -10, dimensions.z - bottom_case_height]) rotate([-5, 0, 0]) cube([dimensions.x + 20, dimensions.y + 20, 20]);
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

*render() translate([pcb_padding.x, pcb_padding.y, plate_top_pcb_offset + plate_offset]) pcb_mock();
