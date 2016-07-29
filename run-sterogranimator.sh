#!/bin/bash

wget -O $1.gif "http://stereo.nypl.org/view/$1.gif?n=1"

convert $1.gif -coalesce +adjoin $1_%01d.png

./run-torchwarp.sh $1
