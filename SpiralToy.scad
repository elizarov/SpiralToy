// Spiral Toy, see https://github.com/elizarov/SpiralToy

$fs = $preview ? 0.5 : 0.1;
$fa = $preview ? 10 : 2;

nLeaf = 7;                     // number of leaves at the botton
rInner = 2;                    // radius of inner sphere, also the half width of each leaf
rLeaf = 16;                    // outer leaf radius (add rInner to get the actual inner radium
twist = 1/2;                   // how many twists spiral makes
rOuter = rLeaf + 3 * rInner;   // outer radis of the bottom of the base
rCap = 2.5;                    // radius of the top cap
hOuterTopCut = 6.0;            // distance of which to cut pointy end of the outer part
hChamfer = 1.0;                // width of chamfer at the bottom (for nice feel)
hOuterBottomTrim = 4.0;        // distance to which the spiral cut extends at the bottom
outerGap = 0.47;               // gap between outer and inner parts

phi = (sqrt(5) + 1) / 2;
hSpiral = 2 * rOuter * phi; // v1 had 50
aTwistOuter = atan(2 * PI * twist * (rLeaf + rInner) / hSpiral);
outerOfs = outerGap / cos(aTwistOuter);

aLeaf = 360 / nLeaf;
rInnerCoreCut = (rInner + outerOfs) / sin(aLeaf / 2);
hOuterTop = hSpiral - rInnerCoreCut * hSpiral / rOuter;
hOuterBottom = hSpiral - (rLeaf + rInner + outerOfs) * hSpiral / rOuter - hOuterBottomTrim;

module base2d(ofs = 0, rIncrease = 0) {
    union() {
        for (i = [0:nLeaf - 1]) {
            rotate(i * 360 / nLeaf, [0, 0, 1]) {
                hull() {
                    circle(rInner + ofs);
                    translate([rLeaf + rIncrease, 0]) {
                        circle(rInner + ofs);
                    }
                }
            }
        }
    }
}


module spiral(ofs = 0, rIncrease = 0) {
    linear_extrude(hSpiral, twist = 360 * twist) {
        base2d(ofs, rIncrease);
    }
}


module outerCone() {
    hyp = sqrt(rOuter^2 + hSpiral^2);
    sz = hyp * rCap / rOuter;
    cz = (sz^2 - rCap^2) / sz;
    cylinder(h = hSpiral - cz , r1 = rOuter, r2 = rOuter * cz / hSpiral);
    translate([0, 0, hSpiral - sz]) {
        sphere(rCap);
    }
}

module outerCut() {
    translate([0, 0, hChamfer]) {
        cylinder(h = hOuterTop - hOuterTopCut - hChamfer, r = rOuter);
    }
    cylinder(h = hChamfer, r1 = rOuter - hChamfer, r2 = rOuter);
}

module outerBottomCut() {
    intersection() {
        translate([0, 0, hOuterBottom]) { 
            cylinder(h = hSpiral - hOuterBottom, r = rOuter);
        }
        spiral(outerOfs, rIncrease = rInner);
    }
}

module innerPart() {
    intersection() {
        spiral();
        outerCone();
    }
}

module outerPart() {
    difference() {
        intersection() {
            outerCone();
            outerCut();
        }
        union() {
            spiral(outerOfs);
            outerBottomCut();
        }
    }
}


//spiral();

//innerPart();
outerPart();

if ($preview) {
    #outerCone();
//    #outerCut();
//    #outerBottomCut();
}