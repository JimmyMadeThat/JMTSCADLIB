/**
 * JMTSCADLIB © 2024 by JimmyMadeThat is licensed under the
 * Attribution-NonCommercial-ShareAlike 4.0 International. To view a copy of this
 * license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/
 */
 
include <bosl2/std.scad>

// Resolution settings
$fa = 1;
$fs = 0.4;

anchor=BOTTOM+FRONT+LEFT;

fudge = 0.001;

module jmt_chamfered_waffle_flat(width=50, height=5, depth=50, cell_width=5, cell_depth=5, chamfer=1, x_offset=-2.5, y_offset=-2.5) {
  
  
  rows = ceil((width + abs(x_offset)) / cell_width);
  columns = ceil((depth + abs(y_offset)) / cell_depth);
  
  base_height = height - chamfer - fudge;
  
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
  [ for (x = [r : sqrt(3) * r : jmt_packed_circles_w_actual(r, w_max) - r + fudge]) x ];
    
function jmt_packed_circles_odd_col_xs(r=1, w_max=1) =
  [ for (x = [r : 2 * sqrt(3) * r : jmt_packed_circles_w_actual(r, w_max) - r + fudge]) x ];
    
function jmt_packed_circles_even_col_xs(r=1, w_max=1) =
  [ for (x = [r + sqrt(3) * r : 2 * sqrt(3) * r : jmt_packed_circles_w_actual(r, w_max) - r + fudge]) x ];

function jmt_packed_circles_odd_row_ys(r=1, d_max=1) =
  [ for (y = [r : 2 * r : jmt_packed_circles_d_actual_odd_rows(r, d_max) - r + fudge]) y ];
  
function jmt_packed_circles_even_row_ys(r=1, d_max=1) =
  [ for (y = [2 * r : 2 * r : jmt_packed_circles_d_actual_even_rows(r, d_max) - r + fudge]) y ];
    
function jmt_packed_circles_odd_col_coords(r=1, w_max=1, d_max=1) =
  [ for (x = jmt_packed_circles_odd_col_xs(r, w_max), y = jmt_packed_circles_odd_row_ys(r, d_max)) [x, y] ];
    
function jmt_packed_circles_even_col_coords(r=1, w_max=1, d_max=1) =
  [ for (x = jmt_packed_circles_even_col_xs(r, w_max), y = jmt_packed_circles_even_row_ys(r, d_max)) [x, y] ];
    
function jmt_packed_circles_col_coords(r=1, w_max=1, d_max=1) =
  concat(
    jmt_packed_circles_odd_col_coords(r, w_max, d_max),
    jmt_packed_circles_even_col_coords(r, w_max, d_max)
  );
    
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