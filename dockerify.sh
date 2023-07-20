#!/usr/bin/env bash

set -e

docker login -u sjaenick https://harbor.computational.bio.uni-giessen.de/

if [ $# -eq 1 ]; then 
  BUILD_IMAGES=$1
else 
  BUILD_IMAGES=`cat build_order | sed -e 's,base,,'`
fi

for f in $BUILD_IMAGES; do
  if [ -f docker/Dockerfile.${f} ]; then
    cp docker/Dockerfile.${f} .
  else
    cp Dockerfile.tmpl Dockerfile.${f}
    sed -i "s,FRAGMENT,${f},g" Dockerfile.${f}
  fi
  docker build -t sjaenick/${f}:latest -f Dockerfile.${f} .
  docker tag sjaenick/${f}:latest harbor.computational.bio.uni-giessen.de/sjaenick/${f}:latest
  rm Dockerfile.${f}
  docker push harbor.computational.bio.uni-giessen.de/sjaenick/${f}:latest
  docker system prune -af
done

