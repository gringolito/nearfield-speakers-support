// tests/arm_spike.scad
// Spike: prove the hull-of-segments approach works for a 3D curved sweep.
// This is throwaway code — once the approach is validated, the real arm.scad
// will use the same technique with proper parameters.

$fn = 32;

// Toy parameters
L = 80;                  // total arc length
TOE = 26;                // plan angle (degrees)
TILT = 12;               // tilt angle (degrees)
ROOT_H = 60;
TIP_H = 30;
W = 40;
N = 16;                  // number of sample points

// Centerline functions (parameter t in [0, 1])
function centerline_pos(t) =
    let(theta_p = TOE * t, theta_s = TILT * t,
        R_plan = L / (TOE * PI / 180),
        R_side = L / (TILT * PI / 180))
    [ L * t,
      R_plan * (1 - cos(theta_p)),
      -R_side * (1 - cos(theta_s)) ];

function centerline_yaw(t) = TOE * t;
function centerline_pitch(t) = -TILT * t;

function cross_section_h(t) = ROOT_H + (TIP_H - ROOT_H) * t;

// Build the arm by hulling consecutive segments
module arm_spike() {
    for (i = [0 : N-1]) {
        t1 = i / N;
        t2 = (i + 1) / N;
        hull() {
            translate(centerline_pos(t1))
                rotate([0, centerline_pitch(t1), centerline_yaw(t1)])
                    linear_extrude(0.1)
                        square([W, cross_section_h(t1)], center = true);
            translate(centerline_pos(t2))
                rotate([0, centerline_pitch(t2), centerline_yaw(t2)])
                    linear_extrude(0.1)
                        square([W, cross_section_h(t2)], center = true);
        }
    }
}

arm_spike();

// Reference markers at endpoints
color("red")  translate(centerline_pos(0)) sphere(3);
color("blue") translate(centerline_pos(1)) sphere(3);
