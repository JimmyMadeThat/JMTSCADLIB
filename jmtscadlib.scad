/**
 * JMTSCADLIB © 2024 by JimmyMadeThat is licensed under the
 * Attribution-NonCommercial-ShareAlike 4.0 International. To view a copy of this
 * license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/
 */
 
include <bosl2/std.scad>

// Resolution settings
//$fa = 1;
//$fs = 0.4;

anchor=BOTTOM+FRONT+LEFT;

f = 0.001;
f2 = 2 * f;

simple=true;

// Chamfered Waffle

module jmt_chamfered_waffle_flat(width=50, height=5, depth=50, cell_width=5, cell_depth=5, chamfer=1, x_offset=-2.5, y_offset=-2.5) {
  rows = ceil((width + abs(x_offset)) / cell_width);
  columns = ceil((depth + abs(y_offset)) / cell_depth);
  
  base_height = height - chamfer - f;
  
  intersection() {
    union() {
      for(r = [0:rows-1]) {
        for(c = [0:columns-1]) {
          x_off = r * cell_width + x_offset;
          y_off = c * cell_depth + y_offset;
          translate([x_off, y_off, 0])
            cuboid([cell_width, cell_depth, height], chamfer=chamfer, anchor=anchor);
        }
      }
      cube([width, depth, base_height]);
    }
    cube([width, depth, height]);
  }
}

// Diamond basket cell texture

module jmt_diamond_basket_cell(w=1, d_min=1, d_max=1, backing=1) {
  r = jmt_diamond_basket_cell_r(d_min, w);
  v_scale = jmt_diamond_basket_cell_v_scale(d_min, d_max, w);
  side = jmt_diamond_basket_cell_side(w);
  
  if (simple) {
    translate([0, -d_min-f, 0])
    union() {
      translate([0, d_min, w/2])
        rotate([0, 45, 0])
        cube([side, d_max+backing+f-d_min, side]);
      translate([w/4, 0, w/2])
        rotate([0, 45, 0])
        cube([side/2, d_max+backing+f, side/2]);
    
    }
  } else {
    translate([0,-d_min-f,0])
    union() {
      intersection() {
        translate([w/2, r, w/2])
          scale([1,1,v_scale])
          sphere(r=r);
        translate([0, -f, w/2])
          rotate([0, 45, 0])
          cube([side, d_max+f, side]);
      }
      translate([0, d_max-f, w/2])
        rotate([0, 45, 0])
        cube([side, backing, side]);
    }
  }
}

module jmt_diamond_basket_straight_wall(w=50, h=50, cell_w=15, d_min=3, d_max=5, backing=0, x_offset=0) {
  
  intersection() {
    union() {
      for (x = [-0.5*cell_w+x_offset:cell_w:w+f], z=[-0.5*cell_w:cell_w:w+f]) {
        translate([x, 0, z])
          jmt_diamond_basket_cell(w=cell_w+f, d_min=d_min, d_max=d_max, backing=backing);
      }
      for (x = [x_offset:cell_w:w+f], z=[0:cell_w:w+f]) {
        translate([x, 0, z])
          jmt_diamond_basket_cell(w=cell_w+f, d_min=d_min, d_max=d_max, backing=backing);
      }
    }
  }
}

module jmt_diamond_basket_curved_wall(r=50, h=50, deg=90, cell_w=15, d_min=3, d_max=5, backing=0, x_offset=0) {
  theta = jmt_diamond_basket_cell_curved_wall_theta(cell_w, r);
  
  difference() {
    intersection() {
      union() {
        for (a=[-theta:theta:deg], z=[0:cell_w:h+f]) {
          translate([r*cos(a),r*sin(a),z])
            rotate([0,0,90+a+theta/2])
            jmt_diamond_basket_cell(w=cell_w+f, d_min=d_min, d_max=d_max, backing=backing);
        }

        for (a=[-theta/2:theta:deg], z=[-cell_w/2:cell_w:h+f]) {
          translate([r*cos(a),r*sin(a),z])
            rotate([0,0,90+a+theta/2])
            jmt_diamond_basket_cell(w=cell_w+f, d_min=d_min, d_max=d_max, backing=backing);
        }
      }
    }
  }
  
  echo(jmt_diamond_basket_cell_straight_wall_back_thickness(d_min, d_max, backing));
  echo(jmt_diamond_basket_cell_straight_wall_protrusion(d_min, d_max, backing));
  echo(jmt_diamond_basket_cell_straight_wall_thinnest_point(d_min, d_max, backing));
  
  echo(jmt_diamond_basket_cell_curved_wall_back_thickness(d_min, d_max, backing, r, cell_w));
  echo(jmt_diamond_basket_cell_curved_wall_protrusion(d_min, d_max, backing, r, cell_w));
  
  #cylinder(h=h, r=r-jmt_diamond_basket_cell_straight_wall_back_thickness(d_min, d_max, backing));
}

function jmt_diamond_basket_cell_straight_wall_back_thickness(d_min, d_max, d_backing) =
  d_max - d_min + d_backing;

function jmt_diamond_basket_cell_straight_wall_protrusion(d_min, d_max, d_backing) =
  d_min;

function jmt_diamond_basket_cell_straight_wall_thinnest_point(d_min, d_max, d_backing) =
  d_backing;

function jmt_diamond_basket_cell_curved_wall_back_thickness(d_min, d_max, d_backing, r, cell_w) =
  let (t=jmt_diamond_basket_cell_straight_wall_back_thickness(d_min, d_max, d_backing))
    t + r - sqrt(4 * r^2 - cell_w^2) / 2;

function jmt_diamond_basket_cell_curved_wall_protrusion(d_min, d_max, d_backing, r, cell_w) =
  let (
    t=jmt_diamond_basket_cell_straight_wall_back_thickness(d_min, d_max, d_backing),
    d_b=jmt_diamond_basket_cell_curved_wall_back_thickness(d_min, d_max, d_backing, r, cell_w)
  )  
    d_min + t - d_b;

// TODO curved wall thinnest point

// TODO backing for straight wall thinnest point
// TODO backing for curved wall thinnest point

// TODO curved wall inner trim radius
// TODO curved wall outer trim radius

// TODO offset theta

// r for sphere that creates cell
function jmt_diamond_basket_cell_r(d_min=1, w=1) =
  (d_min/2) + (w^2/(8*d_min));

// diagonal side length of cell
function jmt_diamond_basket_cell_side(w) =
  w / sqrt(2);

// theta that each cell covers in curved wall
function jmt_diamond_basket_cell_curved_wall_theta(w, r) =
  2 * asin(w / (2*r));

// vertical scale factor for cell sphere to achieve d_min and d_max
function jmt_diamond_basket_cell_v_scale(d_min=1, d_max=1, w=1) =
  sqrt(2 * jmt_diamond_basket_cell_r(w=w, d_min=d_min) * d_min - d_min^2) / sqrt(2 * jmt_diamond_basket_cell_r(w=w, d_min=d_min) * d_max - d_max^2);

// Sloped cylinder

function jmt_sloped_cylinder_height(r1=1, r2=2, slope=90) =
  (r1 - r2) * tan(slope);

// Packed circles

function jmt_packed_circles_odd_rows(r=1, d_max=1) =
  floor(d_max / (2 * r));

function jmt_packed_circles_even_rows(r=1, d_max=1) =
  floor((d_max - r) / (2 * r));

function jmt_packed_circles_columns(r=1, w_max=1) =
  floor(w_max / (sqrt(3) * r) - 2 / sqrt(3) + 1);

function jmt_packed_circles_w_actual(r=1, w_max=1) =
  r * (sqrt(3) * jmt_packed_circles_columns(r, w_max) + 2 - sqrt(3));

function jmt_packed_circles_d_actual_odd_rows(r=1, d_max=1) =
  2 * r * jmt_packed_circles_odd_rows(r, d_max);

function jmt_packed_circles_d_actual_even_rows(r=1, d_max=1) =
  2 * r * jmt_packed_circles_even_rows(r, d_max) + r;

function jmt_packed_circles_d_actual(r=1, d_max=1) =
  max(
    jmt_packed_circles_d_actual_odd_rows(r, d_max), jmt_packed_circles_d_actual_even_rows(r, d_max)
  );

function jmt_packed_circles_col_xs(r=1, w_max=1) =
  [ for (x = [r : sqrt(3) * r : jmt_packed_circles_w_actual(r, w_max) - r + f]) x ];
    
function jmt_packed_circles_odd_col_xs(r=1, w_max=1) =
  [ for (x = [r : 2 * sqrt(3) * r : jmt_packed_circles_w_actual(r, w_max) - r + f]) x ];
    
function jmt_packed_circles_even_col_xs(r=1, w_max=1) =
  [ for (x = [r + sqrt(3) * r : 2 * sqrt(3) * r : jmt_packed_circles_w_actual(r, w_max) - r + f]) x ];

function jmt_packed_circles_odd_row_ys(r=1, d_max=1) =
  [ for (y = [r : 2 * r : jmt_packed_circles_d_actual_odd_rows(r, d_max) - r + f]) y ];
  
function jmt_packed_circles_even_row_ys(r=1, d_max=1) =
  [ for (y = [2 * r : 2 * r : jmt_packed_circles_d_actual_even_rows(r, d_max) - r + f]) y ];
    
function jmt_packed_circles_odd_col_coords(r=1, w_max=1, d_max=1) =
  [ for (x = jmt_packed_circles_odd_col_xs(r, w_max), y = jmt_packed_circles_odd_row_ys(r, d_max)) [x, y] ];
    
function jmt_packed_circles_even_col_coords(r=1, w_max=1, d_max=1) =
  [ for (x = jmt_packed_circles_even_col_xs(r, w_max), y = jmt_packed_circles_even_row_ys(r, d_max)) [x, y] ];
    
function jmt_packed_circles_col_coords(r=1, w_max=1, d_max=1) =
  concat(
    jmt_packed_circles_odd_col_coords(r, w_max, d_max),
    jmt_packed_circles_even_col_coords(r, w_max, d_max)
  );
  
//jmt_diamond_basket_cell(w=15, d_min=2, d_max=6, backing=0);
//jmt_diamond_basket_straight_wall(w=50, h=50, d_min=0.5, d_max=2, cell_w=15);
//jmt_diamond_basket_curved_wall(r=50, h=50, deg=90, d_min=0.5, d_max=2, cell_w=15);

/*
r_base = 38.6 / 2;
space = 1;
r = r_base + space;
w_max = 174;
d_max = 174;
  
w_actual = jmt_packed_circles_w_actual(r, w_max);
d_actual = jmt_packed_circles_d_actual(r, d_max);
  
echo(r);
  
echo(jmt_packed_circles_columns(r, w_max));
echo(jmt_packed_circles_w_actual(r, w_max));
echo(jmt_packed_circles_col_xs(r, w_max));
  
echo(jmt_packed_circles_odd_rows(r, d_max));
echo(jmt_packed_circles_even_rows(r, d_max));
echo(jmt_packed_circles_d_actual(r, d_max));
  
echo(jmt_packed_circles_odd_row_ys(r, d_max));
echo(jmt_packed_circles_even_row_ys(r, d_max));
  
echo(jmt_packed_circles_odd_col_coords(r, w_max, d_max));

for (xy = jmt_packed_circles_col_coords(r, w_max, d_max)) {
  translate([xy[0], xy[1], 0])
    cylinder(r=r, h=50);
}
  
cube([w_max, d_max, 1]);
cube([w_actual, d_actual, 2]);
*/