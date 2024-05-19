#!/bin/bash

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

# shellcheck disable=SC1091
source .env set

gdal_translate -a_ullr \
  "$(echo "${upperLeftX:?} + $OFFSET_X" | bc -l)" \
  "$(echo "${upperLeftY:?} + $OFFSET_Y" | bc -l)" \
  "$(echo "${lowerRightX:?} + $OFFSET_X" | bc -l)" \
  "$(echo "${lowerRightY:?} + $OFFSET_Y" | bc -l)" \
  map.tif translated.tif

echo "${green}Splitting to separate bands${normal}"

# https://gis.stackexchange.com/questions/431939/terracotta-showing-map-in-bw#comment705169_432224
gdal_translate -b 1 translated.tif map_red.tif
gdal_translate -b 2 translated.tif map_green.tif
gdal_translate -b 3 translated.tif map_blue.tif
gdal_translate -b 4 translated.tif map_alpha.tif

echo "${green}Optimizing layers${normal}"
terracotta optimize-rasters map_*.tif -o optimized/

echo "${green}Ingesting tiles${normal}"
terracotta ingest "optimized/{}_{band}.tif" -o terracotta.sqlite

export TERRACOTTA_API_URL="//${TILE_SERVER}:5000"

# all CORS headers are handled by caddy
export TC_ALLOWED_ORIGINS_METADATA='[]'

CADDY_TLS_CONFIG=""
if [[ -n "${CF_API_TOKEN// /}" ]]; then
    CADDY_TLS_CONFIG=$(cat << EOF
{env.TILE_SERVER}:5443 {
	reverse_proxy * unix//tiles/terracotta.sock
	tls {
		dns cloudflare {env.CF_API_TOKEN}
		resolvers 1.1.1.1
	}
  import cors {header.origin}
}
EOF
)
fi

export CADDY_TLS_CONFIG

echo "${green}Running tile and preview servers${normal}"
procfusion procfusion.toml
