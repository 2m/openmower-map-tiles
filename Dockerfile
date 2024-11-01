FROM python:3.13

ARG TARGETARCH

RUN apt-get update && apt-get install -y \
    gdal-bin libgdal-dev jq bc \
    # for cargo that builds procfusion
    build-essential \
    curl \
    # clean cache for smaller final image
    && rm -rf /var/lib/apt/lists/*

# Download Caddy compiled with the caddy-dns/cloudflare module
ADD --chmod=500 https://caddyserver.com/api/download?os=linux&arch=$TARGETARCH&p=github.com/caddy-dns/cloudflare /usr/bin/caddy

WORKDIR /tiles

ADD requirements.txt requirements.txt
RUN pip install -r requirements.txt

RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

RUN cargo install --git https://github.com/linkdd/procfusion
RUN cargo install cargo-cache
RUN cargo cache -a

ADD map-tiles.sh map-tiles.sh
RUN chmod +x map-tiles.sh

ADD terracotta_patch terracotta_patch/
ADD Caddyfile Caddyfile
ADD procfusion.toml procfusion.toml

# shift the map right (positive) or left (negative) by this many meters
ENV OFFSET_X="0.0"
# shift the map up (positive) or down (negative) by this many meters
ENV OFFSET_Y="0.0"
# tileserver to use for the preview app
ENV TILE_SERVER="localhost"
# terracota DB path
ENV TC_DRIVER_PATH="/tiles/terracotta.sqlite"
# Cloudflare API token for TLS DNS challenge
ENV CF_API_TOKEN=""

# See https://caddyserver.com/docs/conventions#file-locations for details
ENV XDG_CONFIG_HOME /config
ENV XDG_DATA_HOME /data

EXPOSE 5000 5010 5443

CMD ./map-tiles.sh
