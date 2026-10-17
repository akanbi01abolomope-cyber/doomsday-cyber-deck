// DOOMSDAY CYBERDECK — REV 1.0 DESIGN CANDIDATE
// Units: millimetres. Parametric concept; verify all dimensions against real parts.
// Render with OpenSCAD. Set part to "base", "lid", "plate", "drive_cradle", or "assembly".
$fn = 48;
part = "assembly";

// Overall envelope (current design target, not a measured enclosure)
case_x = 360;
case_y = 280;
base_h = 88;
lid_h = 34;
wall = 3;
floor_t = 3;
corner_r = 12;
fit_clearance = 0.6;

// Display opening target; adjust to the measured active module/bezel.
screen_x = 270;
screen_y = 170;
screen_center_y = 8;

// Plate and post geometry. Holes are deliberately aligned.
plate_x = 320;
plate_y = 240;
plate_t = 3;
plate_hole_inset_x = 12;
plate_hole_inset_y = 12;
post_d = 12;
post_hole_d = 4.3; // nominal M4 clearance; verify fastener choice
post_h = 18;
post_x = plate_x/2 - plate_hole_inset_x; // 148
post_y = plate_y/2 - plate_hole_inset_y; // 108

// Generic drive tray only; replace with exact drive dimensions.
drive_x = 147;
drive_y = 102;
drive_z = 27;
drive_wall = 3;
drive_clearance = 1.5;

// Rounded rectangular solid with vertical and horizontal rounded edges.
module rounded_solid(x,y,z,r) {
    minkowski() {
        cube([x-2*r, y-2*r, z-2*r], center=true);
        sphere(r=r);
    }
}

module base_shell() {
    difference() {
        translate([0,0,base_h/2]) rounded_solid(case_x,case_y,base_h,corner_r);
        // Open cavity above floor
        translate([0,0,floor_t+(base_h+10)/2])
            cube([case_x-2*wall,case_y-2*wall,base_h+10],center=true);
        // Fastener holes through floor aligned with plate posts
        for (sx=[-1,1], sy=[-1,1])
            translate([sx*post_x,sy*post_y,-1])
                cylinder(d=post_hole_d,h=floor_t+2);
    }
    // Four internal posts, positioned to align with mounting-plate holes
    for (sx=[-1,1], sy=[-1,1]) {
        translate([sx*post_x,sy*post_y,floor_t])
            difference() {
                cylinder(d=post_d,h=post_h);
                translate([0,0,-1]) cylinder(d=post_hole_d,h=post_h+2);
            }
    }
}

module lid() {
    difference() {
        translate([0,0,lid_h/2]) rounded_solid(case_x,case_y,lid_h,corner_r);
        // Underside recess, leaving a top skin and perimeter flange
        translate([0,0,-2])
            cube([case_x-2*wall,case_y-2*wall,lid_h-2*wall+4],center=true);
        // Screen opening through top
        translate([0,screen_center_y,lid_h-wall/2])
            cube([screen_x,screen_y,wall+3],center=true);
        // Corner fastener clearance holes
        for (sx=[-1,1], sy=[-1,1])
            translate([sx*post_x,sy*post_y,-1])
                cylinder(d=post_hole_d,h=lid_h+2);
    }
}

module mounting_plate() {
    difference() {
        translate([0,0,plate_t/2]) cube([plate_x,plate_y,plate_t],center=true);
        for (sx=[-1,1], sy=[-1,1])
            translate([sx*post_x,sy*post_y,-1])
                cylinder(d=post_hole_d,h=plate_t+2);
        // Adjustable mounting slots. Confirm these don't conflict with real board layouts.
        for (x=[-125:50:125], y=[-85:50:85])
            translate([x,y,-1])
                linear_extrude(height=plate_t+2)
                    hull() {
                        translate([0,-6]) circle(d=5.2);
                        translate([0, 6]) circle(d=5.2);
                    }
    }
}

module drive_cradle() {
    outer_x = drive_x + 2*(drive_wall+drive_clearance);
    outer_y = drive_y + 2*(drive_wall+drive_clearance);
    outer_z = drive_z + drive_wall;
    difference() {
        translate([0,0,outer_z/2]) cube([outer_x,outer_y,outer_z],center=true);
        // Open top, with floor retained
        translate([0,0,drive_wall+(outer_z+2)/2])
            cube([drive_x+2*drive_clearance,drive_y+2*drive_clearance,outer_z+2],center=true);
        for (sx=[-1,1], sy=[-1,1])
            translate([sx*(outer_x/2-9),sy*(outer_y/2-9),-1])
                cylinder(d=4.3,h=drive_wall+2);
    }
}

module assembly_preview() {
    color([0.22,0.26,0.31]) base_shell();
    // Lid is lifted behind the base for visual preview only.
    translate([0,case_y+35,base_h+8]) color([0.42,0.47,0.53]) lid();
    translate([0,0,16]) color([0.72,0.75,0.78]) mounting_plate();
    translate([-85,-45,35]) color([0.62,0.65,0.68]) drive_cradle();
    translate([85,-45,35]) color([0.62,0.65,0.68]) drive_cradle();
}

if (part=="base") base_shell();
else if (part=="lid") lid();
else if (part=="plate") mounting_plate();
else if (part=="drive_cradle") drive_cradle();
else assembly_preview();
