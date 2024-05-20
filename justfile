docker-build:
    docker build . -t openmower-map-tiles

docker-run mapfile:
    docker run -it --rm \
        -v {{mapfile}}:/tiles/map.tif \
        --name openmower-map-tiles \
        --env-file .env \
        -p 5000:5000 \
        -p 5010:5010 \
        -p 5443:5443 \
        openmower-map-tiles
