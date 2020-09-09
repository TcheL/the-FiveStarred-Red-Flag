#!/bin/bash
sc=6
pi=3.14159265

high=${1:-10}

# === check input
if [[ ! ${high} =~ ^[0-9.]+$ ]]; then
  echo "Emmm, I just need a numerical value for high of pic."
  exit 1
fi

long=`echo "scale=${sc}; ${high}*1.5" | bc`
step=`echo "scale=${sc}; ${high}/20.0" | bc`

R=0/${long}/0/${high}
J=x1c
ps=examples/flag.ps

#===============================================================================

function determine_line_parameter() {
# determine_towline_parameter x1 y1 x2 y2
  k=`echo "scale=${sc}; (${2} - ${4})/(${1} - ${3})" | bc`
  b=`echo "scale=${sc}; ${4} - ${k}*${3}" | bc`
  echo "${k} ${b}"
}

function find_twoline_crosspoint() {
# find_twoline_crosspoint k1 b1 k2 b2
  x=`echo "scale=${sc}; (${4} - ${2})/(${1} - ${3})" | bc`
  y=`echo "scale=${sc}; ${1}*${x} + ${2}" | bc`
  echo "${x} ${y}"
}

function find_starpoint_outercircle() {
# find_starpoint_outercircle x0 y0 d ang
  dang=`echo "scale=${sc}; 2*${pi}/5.0" | bc`

  ang=`echo "scale=${sc}; ${4} + ${dang}*0" | bc`
  ox1=`echo "scale=${sc}; ${1} + c(${ang})*${3}/2" | bc -l`
  oy1=`echo "scale=${sc}; ${2} + s(${ang})*${3}/2" | bc -l`

  ang=`echo "scale=${sc}; ${4} + ${dang}*1" | bc`
  ox2=`echo "scale=${sc}; ${1} + c(${ang})*${3}/2" | bc -l`
  oy2=`echo "scale=${sc}; ${2} + s(${ang})*${3}/2" | bc -l`

  ang=`echo "scale=${sc}; ${4} + ${dang}*2" | bc`
  ox3=`echo "scale=${sc}; ${1} + c(${ang})*${3}/2" | bc -l`
  oy3=`echo "scale=${sc}; ${2} + s(${ang})*${3}/2" | bc -l`

  ang=`echo "scale=${sc}; ${4} + ${dang}*3" | bc`
  ox4=`echo "scale=${sc}; ${1} + c(${ang})*${3}/2" | bc -l`
  oy4=`echo "scale=${sc}; ${2} + s(${ang})*${3}/2" | bc -l`

  ang=`echo "scale=${sc}; ${4} + ${dang}*4" | bc`
  ox5=`echo "scale=${sc}; ${1} + c(${ang})*${3}/2" | bc -l`
  oy5=`echo "scale=${sc}; ${2} + s(${ang})*${3}/2" | bc -l`

  echo "${ox1} ${ox2} ${ox3} ${ox4} ${ox5} ${oy1} ${oy2} ${oy3} ${oy4} ${oy5}"
}

function find_starpoint_innercircle() {
# find_starpoint_innercircle ox1 ox2 ox3 ox4 ox5 oy1 oy2 oy3 oy4 oy5

  # === line 1-3 and 2-5
  lp1=`determine_line_parameter ${1} ${6} ${3} ${8}`
  lp2=`determine_line_parameter ${2} ${7} ${5} ${10}`
  isp=(`find_twoline_crosspoint ${lp1} ${lp2}`)
  ix1=${isp[0]}
  iy1=${isp[1]}

  # === line 2-4 and 3-1
  lp1=`determine_line_parameter ${2} ${7} ${4} ${9}`
  lp2=`determine_line_parameter ${3} ${8} ${1} ${6}`
  isp=(`find_twoline_crosspoint ${lp1} ${lp2}`)
  ix2=${isp[0]}
  iy2=${isp[1]}

  # === line 3-5 and 4-2
  lp1=`determine_line_parameter ${3} ${8} ${5} ${10}`
  lp2=`determine_line_parameter ${4} ${9} ${2} ${7}`
  isp=(`find_twoline_crosspoint ${lp1} ${lp2}`)
  ix3=${isp[0]}
  iy3=${isp[1]}

  # === line 4-1 and 5-3
  lp1=`determine_line_parameter ${4} ${9} ${1} ${6}`
  lp2=`determine_line_parameter ${5} ${10} ${3} ${8}`
  isp=(`find_twoline_crosspoint ${lp1} ${lp2}`)
  ix4=${isp[0]}
  iy4=${isp[1]}

  # === line 5-2 and 1-4
  lp1=`determine_line_parameter ${5} ${10} ${2} ${7}`
  lp2=`determine_line_parameter ${1} ${6} ${4} ${9}`
  isp=(`find_twoline_crosspoint ${lp1} ${lp2}`)
  ix5=${isp[0]}
  iy5=${isp[1]}

  echo "${ix1} ${ix2} ${ix3} ${ix4} ${ix5} ${iy1} ${iy2} ${iy3} ${iy4} ${iy5}"
}

function gmt_star() {
# gmt_star x0 y0 d ang

  outerpoints=`find_starpoint_outercircle ${1} ${2} ${3} ${4}`
  innerpoints=`find_starpoint_innercircle ${outerpoints}`

  ops=(`echo ${outerpoints}`)
  ips=(`echo ${innerpoints}`)
  gmt psxy -R${R} -J${J} -Gyellow -K -O >> ${ps} << EOF
    ${ops[0]} ${ops[5]}
    ${ips[0]} ${ips[5]}
    ${ops[1]} ${ops[6]}
    ${ips[1]} ${ips[6]}
    ${ops[2]} ${ops[7]}
    ${ips[2]} ${ips[7]}
    ${ops[3]} ${ops[8]}
    ${ips[3]} ${ips[8]}
    ${ops[4]} ${ops[9]}
    ${ips[4]} ${ips[9]}
    ${ops[0]} ${ops[5]}
EOF
}

function gmt_small_star() {
# gmt_small_star ik jk x0 y0

  x1=`echo "scale=${sc}; ${1}*${step}" | bc`
  y1=`echo "scale=${sc}; ${2}*${step}" | bc`
  d=`echo "scale=${sc}; ${step}*2" | bc`
  ang=`echo "scale=${sc}; a((${y1} - ${4})/(${x1} - ${3})) + ${pi}" | bc -l`
  gmt_star ${x1} ${y1} ${d} ${ang}
}

function gmt_check() {
# gmt_check

  echo " 5 15  6" | awk -v dx=${step} '{print $1*dx, $2*dx, $3*dx}' | \
    gmt psxy -R${R} -J${J} -Sc -K -O >> ${ps}
  echo "10 18  2" | awk -v dx=${step} '{print $1*dx, $2*dx, $3*dx}' | \
    gmt psxy -R${R} -J${J} -Sc -K -O >> ${ps}
  echo "12 16  2" | awk -v dx=${step} '{print $1*dx, $2*dx, $3*dx}' | \
    gmt psxy -R${R} -J${J} -Sc -K -O >> ${ps}
  echo "12 13  2" | awk -v dx=${step} '{print $1*dx, $2*dx, $3*dx}' | \
    gmt psxy -R${R} -J${J} -Sc -K -O >> ${ps}
  echo "10 11  2" | awk -v dx=${step} '{print $1*dx, $2*dx, $3*dx}' | \
    gmt psxy -R${R} -J${J} -Sc -K -O >> ${ps}

  echo "10 18" | awk -v dx=${step} \
    '{printf("%f %f\n %f %f\n", 5*dx, 15*dx, $1*dx, $2*dx)}' | \
    gmt psxy -R${R} -J${J} -K -O >> ${ps}
  echo "12 16" | awk -v dx=${step} \
    '{printf("%f %f\n %f %f\n", 5*dx, 15*dx, $1*dx, $2*dx)}' | \
    gmt psxy -R${R} -J${J} -K -O >> ${ps}
  echo "12 13" | awk -v dx=${step} \
    '{printf("%f %f\n %f %f\n", 5*dx, 15*dx, $1*dx, $2*dx)}' | \
    gmt psxy -R${R} -J${J} -K -O >> ${ps}
  echo "10 11" | awk -v dx=${step} \
    '{printf("%f %f\n %f %f\n", 5*dx, 15*dx, $1*dx, $2*dx)}' | \
    gmt psxy -R${R} -J${J} -K -O >> ${ps}

  high2=`echo "scale=${sc}; ${high}/2" | bc`
  long2=`echo "scale=${sc}; ${long}/2" | bc`
  gmt psbasemap -Bxfg${long2} -Byfg${high2} -R${R} -J${J} -K -O >> ${ps}

  high20=`echo "scale=${sc}; ${high}/20" | bc`
  long30=`echo "scale=${sc}; ${long}/30" | bc`
  gmt psbasemap -Y${high2} -Bxg${long30} -Byg${high20} \
    -R0/${long2}/0/${high2} -J${J} -K -O >> ${ps}
}

#===============================================================================

gmt set PS_MEDIA A0
gmt psxy -R${R} -J${J} -P -T -K > ${ps}

gmt psbasemap -R${R} -J${J} -B+gred -K -O >> ${ps}

# === the big star
x0=`echo "scale=${sc}; 5*${step}" | bc`
y0=`echo "scale=${sc}; 15*${step}" | bc`
d=`echo "scale=${sc}; 3*${step}*2" | bc`
echo "${x0} ${y0}" | gmt psxy -R${R} -J${J} -Sa${d} -Gyellow -K -O >> ${ps}
# gmt_star ${x0} ${y0} ${d} 90.0

# === the small stars
gmt_small_star 10 18 ${x0} ${y0}
gmt_small_star 12 16 ${x0} ${y0}
gmt_small_star 12 13 ${x0} ${y0}
gmt_small_star 10 11 ${x0} ${y0}

# gmt_check

gmt psxy -R${R} -J${J} -T -O >> ${ps}
# gmt psconvert -TG -A ${ps} # png
# gmt psconvert -Te -A ${ps} # eps
gmt psconvert -Tf -A ${ps} # pdf

rm -f gmt.conf gmt.history ${ps}

