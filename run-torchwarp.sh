#!/bin/bash

BASENAME=$(basename $1)

convert -verbose $1_0.png PNG24:${BASENAME}_normalized_0.png
convert -verbose $1_1.png PNG24:${BASENAME}_normalized_1.png

./makeOptFlow.sh ${BASENAME}_normalized_%01d.png $BASENAME 0

SEQUENCE=`seq 0.00 0.05 1.00`

for scale in $SEQUENCE; do
  echo $scale
  th torch_warp.lua \
    -flow_file $BASENAME/backward_1_0.flo \
    -source_image ${BASENAME}_normalized_0.png \
    -output_image warped_${BASENAME}_0_$scale.png \
    -scale $scale
  th torch_warp.lua \
    -flow_file $BASENAME/forward_0_1.flo \
    -source_image ${BASENAME}_normalized_1.png \
    -output_image warped_${BASENAME}_1_$scale.png \
    -scale $(bc <<< "1.0-$scale")
  convert warped_${BASENAME}_0_$scale.png warped_${BASENAME}_1_$scale.png -compose blend -define compose:args=$(bc <<< "100*$scale/1") -composite blended_${BASENAME}_$scale.png
done

convert $(ls blended_${BASENAME}_*.png) $(ls blended_${BASENAME}_*.png | tac | sed '1d;$d') -delay 10 -loop 0 morphed_$BASENAME.gif
