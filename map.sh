#!/bin/sh
ogr2ogr labels.geojson labels.csv -oo X_POSSIBLE_NAMES=longitude -oo Y_POSSIBLE_NAMES=latitude

mapshaper \
  -graticule interval=5 \
  -i ne_10m_admin_0_countries/*.shp name=countries \
  -dissolve target=countries + name=land \
  -innerlines target=countries + name=inner-borders \
  -lines target=land + name=outer-borders \
  -merge-layers force target=inner-borders,outer-borders name=borders \
  -i ne_10m_railroads/*.shp name=rail \
  -filter "scalerank <= 8" \
  -i signal-eu-org.geojson name=route \
  -buffer target=route radius=5000 + name=route-buffer \
  -erase source=route-buffer target=rail \
  -i track.geojson name=track -lines -buffer 5000 \
  -clip source=track target=route + name=route-travelled \
  -erase source=track target=route + name=route-ahead \
  -i labels.geojson name=labels-points \
  -i labels.geojson name=labels-text \
  -style target=land fill="#fff" \
  -style target=borders stroke="#222" stroke-width=0.5 \
  -style target=rail stroke="#ccc" stroke-width=1 \
  -style target=graticule stroke="#999" stroke-width=0.5 \
  -style target=route-travelled stroke-width=4 stroke="#c00" \
  -style target=route-ahead stroke-width=2 stroke="#fff" opacity=0.9 \
  -style target=route stroke-width=3 stroke="#c00" \
  -style target=labels-points label-text="" r=4 fill="#c00" \
  -style target=labels-text font-family="Concourse OT" font-weight=600 font-size=12 fill="#000" \
  -proj from=wgs84 ESRI:102014 target=graticule,land,borders,rail,route,route-ahead,route-travelled,labels-text,labels-points \
  -rectangle route offset=15% + name=bg \
  -style bg fill="#eee" \
  -clip bg target=graticule \
  -clip bg target=land \
  -clip bg target=borders \
  -clip bg target=rail \
  -o map.svg target=bg,graticule,land,rail,borders,labels-points,route,route-ahead,route-travelled,labels-text width=500 \
  -calc "Math.round(sum($.length)) / 1000" target=route \
  -calc "Math.round(sum($.length)) / 1000" target=route-travelled \
  -calc "Math.round(sum($.length)) / 1000" target=route-ahead
