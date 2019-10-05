#!/bin/bash
sc=6
pi=3.14159265

high=10

long=`echo "scale=${sc}; ${high}*1.5" | bc`
step=`echo "scale=${sc}; ${high}/20.0" | bc`

R=0/${long}/0/${high}
J=x1c
ps=examples/flag.ps

#===============================================================================

function determine_line_parameter() {
# determine_towline_parameter x1 y1 x2 y2
  k1=`echo "scale=${sc}; (${2} - ${4})/(${1} - ${3})" | bc`
  b1=`echo "scale=${sc}; ${4} - ${k1}*${3}" | bc`
  echo "${k1} ${b1}"
}

function find_twoline_crosspoint() {
# find_twoline_crosspoint k1 b1 k2 b2
  x=`echo "scale=${sc}; (${4} - ${2})/(${1} - ${3})" | bc`
  y=`echo "scale=${sc}; ${1}*${x} + ${2}" | bc`
  echo "${x} ${y}"
}

function find_starpoint_circumcircle() {
# find_starpoint_circumcircle x0 y0 d ang
  dang=`echo "scale=${sc}; 2*${pi}/5.0" | bc`

  ang=${4}
  cx1=`echo "scale=${sc}; ${1} + c(${ang})*${3}/2" | bc -l`
  cy1=`echo "scale=${sc}; ${2} + s(${ang})*${3}/2" | bc -l`

  ang=`echo "scale=${sc}; ${ang} + ${dang}" | bc`
  cx2=`echo "scale=${sc}; ${1} + c(${ang})*${3}/2" | bc -l`
  cy2=`echo "scale=${sc}; ${2} + s(${ang})*${3}/2" | bc -l`

  ang=`echo "scale=${sc}; ${ang} + ${dang}" | bc`
  cx3=`echo "scale=${sc}; ${1} + c(${ang})*${3}/2" | bc -l`
  cy3=`echo "scale=${sc}; ${2} + s(${ang})*${3}/2" | bc -l`

  ang=`echo "scale=${sc}; ${ang} + ${dang}" | bc`
  cx4=`echo "scale=${sc}; ${1} + c(${ang})*${3}/2" | bc -l`
  cy4=`echo "scale=${sc}; ${2} + s(${ang})*${3}/2" | bc -l`

  ang=`echo "scale=${sc}; ${ang} + ${dang}" | bc`
  cx5=`echo "scale=${sc}; ${1} + c(${ang})*${3}/2" | bc -l`
  cy5=`echo "scale=${sc}; ${2} + s(${ang})*${3}/2" | bc -l`

  echo "${cx1} ${cx2} ${cx3} ${cx4} ${cx5} ${cy1} ${cy2} ${cy3} ${cy4} ${cy5}"
}

function find_starpoint_incircle() {
# find_starpoint_incircle cx1 cx2 cx3 cx4 cx5 cy1 cy2 cy3 cy4 cy5

  # line 1-3 and 2-5
  lp1=`determine_line_parameter ${1} ${6} ${3} ${8}`
  lp2=`determine_line_parameter ${2} ${7} ${5} ${10}`
  isp=(`find_twoline_crosspoint ${lp1} ${lp2}`)
  ix1=${isp[0]}
  iy1=${isp[1]}

  # line 2-4 and 3-1
  lp1=`determine_line_parameter ${2} ${7} ${4} ${9}`
  lp2=`determine_line_parameter ${3} ${8} ${1} ${6}`
  isp=(`find_twoline_crosspoint ${lp1} ${lp2}`)
  ix2=${isp[0]}
  iy2=${isp[1]}

  # line 3-5 and 4-2
  lp1=`determine_line_parameter ${3} ${8} ${5} ${10}`
  lp2=`determine_line_parameter ${4} ${9} ${2} ${7}`
  isp=(`find_twoline_crosspoint ${lp1} ${lp2}`)
  ix3=${isp[0]}
  iy3=${isp[1]}

  # line 4-1 and 3-5
  lp1=`determine_line_parameter ${4} ${9} ${1} ${6}`
  lp2=`determine_line_parameter ${3} ${8} ${5} ${10}`
  isp=(`find_twoline_crosspoint ${lp1} ${lp2}`)
  ix4=${isp[0]}
  iy4=${isp[1]}

  # line 5-2 and 1-4
  lp1=`determine_line_parameter ${5} ${10} ${2} ${7}`
  lp2=`determine_line_parameter ${1} ${6} ${4} ${9}`
  isp=(`find_twoline_crosspoint ${lp1} ${lp2}`)
  ix5=${isp[0]}
  iy5=${isp[1]}

  echo "${ix1} ${ix2} ${ix3} ${ix4} ${ix5} ${iy1} ${iy2} ${iy3} ${iy4} ${iy5}"
}

function gmt_star() {
# gmt_star x0 y0 d ang

  circumpoints=`find_starpoint_circumcircle ${1} ${2} ${3} ${4}`
  inpoints=`find_starpoint_incircle ${circumpoints}`

  circums=(`echo ${circumpoints}`)
  ins=(`echo ${inpoints}`)
  gmt psxy -R${R} -J${J} -Gyellow -K -O >> ${ps} << EOF
    ${circums[0]} ${circums[5]}
    ${ins[0]} ${ins[5]}
    ${circums[1]} ${circums[6]}
    ${ins[1]} ${ins[6]}
    ${circums[2]} ${circums[7]}
    ${ins[2]} ${ins[7]}
    ${circums[3]} ${circums[8]}
    ${ins[3]} ${ins[8]}
    ${circums[4]} ${circums[9]}
    ${ins[4]} ${ins[9]}
    ${circums[0]} ${circums[5]}
EOF
}

function gmt_small_star() {
# gmt_small_star ix iy x0 y0

  x1=`echo "scale=${sc}; ${1}*${step}" | bc`
  y1=`echo "scale=${sc}; ${2}*${step}" | bc`
  d=`echo "scale=${sc}; ${step}*2" | bc`
  ang=`echo "scale=${sc}; a((${y1} - ${4})/(${x1} - ${3})) + ${pi}" | bc -l`
  gmt_star ${x1} ${y1} ${d} ${ang}
}

#===============================================================================

gmt set PS_MEDIA A0
gmt psxy -R${R} -J${J} -P -T -K > ${ps}

gmt psbasemap -R${R} -J${J} -B+gred -K -O >> ${ps}

# the big star
x0=`echo "scale=${sc}; 5*${step}" | bc`
y0=`echo "scale=${sc}; 15*${step}" | bc`
d=`echo "scale=${sc}; 3*${step}*2" | bc`
echo "${x0} ${y0}" | gmt psxy -R${R} -J${J} -Sa${d} -Gyellow -K -O >> ${ps}
# gmt_star ${x0} ${y0} ${d} 0.0

# the small stars
gmt_small_star 10 18 ${x0} ${y0}
gmt_small_star 12 16 ${x0} ${y0}
gmt_small_star 12 13 ${x0} ${y0}
gmt_small_star 10 11 ${x0} ${y0}

gmt psxy -R${R} -J${J} -T -O >> ${ps}
# gmt psconvert -TG -A ${ps} # png
# gmt psconvert -Te -A ${ps} # eps
gmt psconvert -Tf -A ${ps} # pdf

rm -f gmt.conf gmt.history ${ps}

