#!/bin/bash

cd /tiles || exit

# terminal colors
normal=$'\e[0m'
bold=$(tput bold)
green="$bold$(tput setaf 2)"

echo "${green}Shifting by X:${OFFSET_X} and Y:${OFFSET_Y}${normal}"

gdalinfo -json map.tif | jq -r '
    .cornerCoordinates |
    to_entries |
    map(["\(.key)X=\(.value[0])", "\(.key)Y=\(.value[1])"]) |
    flatten[]'\
  | tee .env
source .env set

gdal_translate -a_ullr \
  "$(echo "$upperLeftX + $OFFSET_X" | bc -l)" \
  "$(echo "$upperLeftY + $OFFSET_Y" | bc -l)" \
  "$(echo "$lowerRightX + $OFFSET_X" | bc -l)" \
  "$(echo "$lowerRightY + $OFFSET_Y" | bc -l)" \
  map.tif translated.tif

echo "${green}Splitting to separate bands${normal}"

# https://gis.stackexchange.com/questions/431939/terracotta-showing-map-in-bw#comment705169_432224
gdal_translate -b 1 translated.tif map_red.tif
gdal_translate -b 2 translated.tif map_green.tif
gdal_translate -b 3 translated.tif map_blue.tif
gdal_translate -b 4 translated.tif map_alpha.tif

echo "${green}Optimizing layers${normal}"
terracotta optimize-rasters map_*.tif -o optimized/

echo "${green}Starting XYZ tile server${normal}"
terracotta serve --allow-all-ips -r "optimized/{}_{band}.tif" &
sleep 5

echo "${green}Starting preview server${normal}"
terracotta connect localhost:5000 &

# "terracotta connect" listens to localhost
# this forwards connections from all interfaces to localhost
socat TCP-LISTEN:5010,fork TCP:localhost:5100
