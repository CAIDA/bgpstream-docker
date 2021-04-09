#!/usr/bin/env bash

docker build -f Dockerfile.unstable -t caida/bgpstream:unstable .

# use command `docker login` to save login credentials to dockerhub
# use command `docker tag IMAGEID caida/bgpstream:TAG` to duplicate image with different tag name
# use command `docker push caida/bgpstream:TAG` to push it to dockerhub
