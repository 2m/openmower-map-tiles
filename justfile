docker-build:
    docker build . -t openmower-map-tiles

docker-run mapfile tile_server offset_x offset_y:
    docker run -it --rm \
        -v {{mapfile}}:/tiles/map.tif \
        --name openmower-map-tiles \
        --env OFFSET_X={{offset_x}} \
        --env OFFSET_Y={{offset_y}} \
        --env TILE_SERVER={{tile_server}} \
        -p 5000:5000 \
        -p 5010:5010 \
        openmower-map-tiles
