#!/bin/bash
# Copyright (C) 2012 - 2015  Anders Gidenstam  (anders(at)gidenstam.org)
# This file is licensed under the GPL license version 2 or later.
#
# Usage: create_experiment.sh <base dir> <name base>

BASEDIR=$1
BASE=$2

# Hydrodynamic reference point [m].
# Relative the origin of the 3d model.
HRPX=0
HRPZ=0

# Water level below the HRP [m].
#HAGL=1.2192 # 4ft
#HAGL=1.524  # 5ft
#HAGL=1.8288 # 6ft
#HAGL=2.1336 # 7ft
#HAGL=2.4384 # 8ft
HAGL=2.7432   # 9ft

# Compute actual model offsets.
XOFFSET=`echo -$HRPX | bc`
ZOFFSET=`echo $HAGL-$HRPZ | bc`

#echo $ZOFFSET
#exit

if [ ! -d ${BASEDIR} ]
then
  mkdir ${BASEDIR}
fi
cd ${BASEDIR}

for roll in -8 -4 -2 0 2 4 8; do
  for pitch in -8 -4 -2 0 2 4 8 12; do
    dir=${BASE}_r${roll}_p${pitch}
    mkdir ${dir}
    transform --tx=$XOFFSET --tz=$ZOFFSET < ../floats.gts.base | transform --ry ${pitch} | transform --rx ${roll} -v > ${dir}/floats.gts

    (cd ${dir}; ln -s ../../buoyancy3D.gfs . )
  done;
done;
