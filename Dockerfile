FROM python:3.11

RUN apt-get update
RUN apt-get install -y gdal-bin libgdal-dev socat jq bc

RUN pip install terracotta

ADD map-tiles.sh map-tiles.sh
RUN chmod +x map-tiles.sh

# shift the map right (positive) or left (negative) by this many meters
ENV OFFSET_X="0.0"
# shift the map up (positive) or down (negative) by this many meters
ENV OFFSET_Y="0.0"
# tileserver to use for the preview app
ENV TILE_SERVER="localhost:5000"

EXPOSE 5000 5010

CMD ./map-tiles.sh
