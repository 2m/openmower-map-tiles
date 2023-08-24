# OpenMower Map Tiles

This repository contains configuration for the [terracotta][] XYZ tile server for custom [OpenMower][openmower] maps.

![demo][]

[terracotta]: https://github.com/DHI-GRAS/terracotta
[openmower]:  https://openmower.de/
[demo]:       ./demo.png

# Usage

## Taking pictures with a drone

If your drone is supported by mission control software like [Map Pilot Pro][map-pilot-pro], [QGroundControl][qgroundcontrol] or others, you can use these tools to create a mission. However it is perfectly fine to manually fly the drone and take pictures. You can get pretty good results by flying at 30m to 40m altitude and taking pictures every couple of meters.

## Stiching the pictures to a single ortophoto

Place all of the pictures in a single directory like `./<dataset-name>/images/`. Then run [OpenDroneMap][odm] to create a single ortophoto:

```bash
docker run -ti --rm -v $PWD:/datasets opendronemap/odm \
  --project-path /datasets <dataset-name> \
  --dsm --orthophoto-resolution 1
```

After it is done, you should have a `./<dataset-name>/odm_orthophoto/odm_orthophoto.tif` file. As a bonus, `odm` also creates 3D models and point clouds of the area. Check them out, they are prety cool. :)

## Running XYZ tile server

Now you can start the XYZ tile server from this repository:

```bash
docker run -ti --rm \
  -v <absolute-path-to-odm_orthophoto.tif>:/tiles/map.tif \
  -p 5000:5000 \
  -p 5010:5010 \
  ghcr.io/2m/openmower-map-tiles:main
```

This will split the given TIF file to different color bands (required by `terracotta`) and start both, the tile server and the preview GUI.

Open `http://localhost:5010` and select `alpha` in the Bands list. Then select `rgb` in the `Customize layer` dropdown. Assign R, G and B bands their corresponding values and you should see the map.

![preview][]

XYZ tile server is available at `http://localhost:5000/rgb/{z}/{x}/{y}.png?r=red&g=green&b=blue`

[map-pilot-pro]:     https://dronesmadeeasy.com/map-pilot
[qgroundcontrol]:    http://qgroundcontrol.com/
[odm]:               https://github.com/OpenDroneMap/ODM
[preview]:           ./preview.png

## Running on the OpenMower

Copy the ortophoto file `odm_orthophoto.tif` to the OpenMower:

```bash
scp odm_orthophoto.tif openmower@openmower.local:
```

Copy the [`map-tiles.service`][map-tiles-service] file in `/etc/systemd/system/` on your OpenMower. Then enable and start the service:

```bash
sudo systemctl enable map-tiles.service
sudo systemctl start map-tiles.service
```

[map-tiles-service]: ./map-tiles.service
