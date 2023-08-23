#!/bin/bash

cd /tiles || exit

# https://gis.stackexchange.com/questions/431939/terracotta-showing-map-in-bw#comment705169_432224
gdal_translate -b 1 map.tif map_red.tif
gdal_translate -b 2 map.tif map_green.tif
gdal_translate -b 3 map.tif map_blue.tif
gdal_translate -b 4 map.tif map_alpha.tif

terracotta optimize-rasters map_*.tif -o optimized/

terracotta serve --allow-all-ips -r "optimized/{}_{band}.tif" &
sleep 5

terracotta connect localhost:5000 &

# "terracotta connect" listens to localhost
# this forwards connections from all interfaces to localhost
socat TCP-LISTEN:5010,fork TCP:localhost:5100
