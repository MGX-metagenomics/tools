#!/usr/bin/env bash

set -e

docker login -u sjaenick https://harbor.computational.bio.uni-giessen.de/

for f in `cat build_order | sed -e 's,base,,'`; do
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

