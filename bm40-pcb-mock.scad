include <variables.scad>
include <roundedCube.scad>

$fa = 1;
$fs = 0.4;

module pcb_mock() {
	color("#094D1C") {
		difference() {
			roundedCube(pcb, 0.3);
			for(screw_position = screw_positions) {
				translate([screw_position.x, screw_position.y, -1]) cylinder(3, 1, 1);
			}
		}
	}
	color("#43464B") {
		translate([usb_position - usb_socket.x / 2, -2, pcb.z]) roundedCube(usb_socket, 1, false, true, false);
	}
	color("#FFD300") translate(reset_button) cylinder(2, 1, 1);
}

pcb_mock();