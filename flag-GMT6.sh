#!/bin/bash

high=${1:-10}
fmt=${2:-pdf}
scset=6
tmp=/tmp/flag.$$.tmp

long=`echo "scale=${scset}; ${high}*1.5" | bc`

# === check input
if [[ ! ${high} =~ ^[0-9.]+$ ]]; then
  echo "Emmm, I just need a numerical value for high of pic."
  exit 1
fi
if [ ${fmt} != "pdf" -a ${fmt} != "eps" -a \
     ${fmt} != "png" -a ${fmt} != "ps" ]; then
  echo "Emmm, I can't export a file with the specified format."
  exit 1
fi

#===============================================================================

bc -l > ${tmp} << EOF
scale = ${scset}
pi = 3.14159265

/* determine_line_parameter */
define dlp_k(x1, y1, x2, y2) { return (y1 - y2)/(x1 - x2) }
define dlp_b(k, x2, y2) { return y2 - k*x2 }

/* find_twoline_crosspoint */
define ftc_x(k1, b1, k2, b2) { return (b2 - b1)/(k1 - k2) }
define ftc_y(x, k1, b1) { return k1*x + b1 }

/* find_starpoint_outercircle for the i-th point */
define fso_x(x0, d, azm, i) {
  ang = azm + (i - 1)*(2*pi/5)
  return x0 + c(ang)*d/2
}
define fso_y(y0, d, azm, i) {
  ang = azm + (i - 1)*(2*pi/5)
  return y0 + s(ang)*d/2
}

define void print_find_starpoint(x0, y0, d, azm) {
  for(i = 1; i <= 5; i++) {
    ox[i] = fso_x(x0, d, azm, i)
    oy[i] = fso_y(y0, d, azm, i)
  }

  /* find_starpoint_innercircle */
  for(i = 1; i <= 5; i++) {
    scale = 0
    j = (i + 1)%5 + 1
    m = i%5 + 1
    n = (i + 3)%5 + 1
    scale = ${scset}

    k1 = dlp_k(ox[i], oy[i], ox[j], oy[j])
    b1 = dlp_b(k1, ox[j], oy[j])
    k2 = dlp_k(ox[m], oy[m], ox[n], oy[n])
    b2 = dlp_b(k2, ox[n], oy[n])

    ix[i] = ftc_x(k1, b1, k2, b2)
    iy[i] = ftc_y(ix[i], k1, b1)
  }

  for(i = 1; i <= 5; i++) {
    print ox[i], " ", oy[i], "\n"
    print ix[i], " ", iy[i], "\n"
  }
  print ox[1], " ", oy[1], "\n"
}

define calculate_azimuth(x0, y0, xs, ys) {
  return a((ys - y0)/(xs - x0)) + pi
}

step = ${high}/20.0

/* the background rectangle */
print "> -Gred \n"
print 0, "\t", 0, "\n"
print ${long}, "\t", 0, "\n"
print ${long}, "\t", ${high}, "\n"
print 0, "\t", ${high}, "\n"
print 0, "\t", 0, "\n"

/* the big star */
x0 = 5*step
y0 = 15*step
d0 = 3*step*2
print "> -Gyellow \n"
print_find_starpoint(x0, y0, d0, pi/2)

ds = step*2

/* the small star 1 */
x1 = 10*step
y1 = 18*step
azm = calculate_azimuth(x0, y0, x1, y1)
print "> -Gyellow \n"
print_find_starpoint(x1, y1, ds, azm)

/* the small star 2 */
x2 = 12*step
y2 = 16*step
azm = calculate_azimuth(x0, y0, x2, y2)
print "> -Gyellow \n"
print_find_starpoint(x2, y2, ds, azm)

/* the small star 3 */
x3 = 12*step
y3 = 13*step
azm = calculate_azimuth(x0, y0, x3, y3)
print "> -Gyellow \n"
print_find_starpoint(x3, y3, ds, azm)

/* the small star 4 */
x4 = 10*step
y4 = 11*step
azm = calculate_azimuth(x0, y0, x4, y4)
print "> -Gyellow \n"
print_find_starpoint(x4, y4, ds, azm)

EOF

#===============================================================================

function gmt_check() {
  chtmp=/tmp/flag.check.$$.tmp

  bc -l > ${chtmp} << EOF
    scale = ${scset}
    step = ${high}/20.0
    print  5*step, ", ", 15*step, ", ", 6*step, "\n"
    print 10*step, ", ", 18*step, ", ", 2*step, "\n"
    print 12*step, ", ", 16*step, ", ", 2*step, "\n"
    print 12*step, ", ", 13*step, ", ", 2*step, "\n"
    print 10*step, ", ", 11*step, ", ", 2*step, "\n"
EOF
  gmt plot ${chtmp} -Sc

  bc -l > ${chtmp} << EOF
    scale = ${scset}
    step = ${high}/20.0
    print "> \n", 5*step, ",", 15*step, "\n"
    print 10*step, ",", 18*step, "\n"
    print "> \n", 5*step, ",", 15*step, "\n"
    print 12*step, ",", 16*step, "\n"
    print "> \n", 5*step, ",", 15*step, "\n"
    print 12*step, ",", 13*step, "\n"
    print "> \n", 5*step, ",", 15*step, "\n"
    print 10*step, ",", 11*step, "\n"
EOF
  gmt plot ${chtmp}

  high2=`echo "scale=${scset}; ${high}/2" | bc`
  long2=`echo "scale=${scset}; ${long}/2" | bc`
  gmt basemap -Bxfg${long2} -Byfg${high2}

  high20=`echo "scale=${scset}; ${high}/20" | bc`
  long30=`echo "scale=${scset}; ${long}/30" | bc`
  gmt basemap -Y${high2} -R0/${long2}/0/${high2} -Bxg${long30} -Byg${high20}

  rm -f ${chtmp}
}

#===============================================================================

gmt begin examples/flag ${fmt}
  gmt plot ${tmp} -R0/${long}/0/${high} -Jx1c
# gmt_check
gmt end show

rm -f ${tmp}
