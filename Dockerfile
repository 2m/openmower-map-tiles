FROM python:3.11

RUN apt-get update
RUN apt-get install -y gdal-bin libgdal-dev socat

RUN pip install terracotta

ADD map-tiles.sh map-tiles.sh
RUN chmod +x map-tiles.sh

EXPOSE 5000 5010

CMD ./map-tiles.sh
