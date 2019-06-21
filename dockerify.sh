#!/usr/bin/env bash

set -e

for f in `cat build_order | sed -e 's,base,,'`; do
  cp Dockerfile.tmpl Dockerfile.${f}
  sed -i "s,FRAGMENT,${f},g" Dockerfile.${f}
  docker build -t sjaenick/${f} -f Dockerfile.${f} .
  rm Dockerfile.${f}
  docker push sjaenick/${f}
  docker system prune -af
done
