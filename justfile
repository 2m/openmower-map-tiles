docker-build:
    docker build . -t openmower-map-tiles

docker-run mapfile:
    docker run --rm \
        -v {{mapfile}}:/tiles/map.tif \
        --name openmower-map-tiles \
        -p 5000:5000 \
        -p 5010:5010 \
        openmower-map-tiles
