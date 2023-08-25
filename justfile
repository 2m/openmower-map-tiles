docker-build:
    docker build . -t openmower-map-tiles

docker-run mapfile offset_x offset_y:
    docker run -it --rm \
        -v {{mapfile}}:/tiles/map.tif \
        --name openmower-map-tiles \
        --env OFFSET_X={{offset_x}} \
        --env OFFSET_Y={{offset_y}} \
        -p 5000:5000 \
        -p 5010:5010 \
        openmower-map-tiles
