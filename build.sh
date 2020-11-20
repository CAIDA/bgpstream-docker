#!/usr/bin/env bash

if [ $# -eq 0 ]
then
    tag='latest'
else
    tag=$1
fi

docker build -f Dockerfile.latest -t caida/bgpstream:$tag .

# use command `docker login` to save login credentials to dockerhub
# use command `docker tag IMAGEID caida/bgpstream:TAG` to duplicate image with different tag name
# use command `docker push caida/bgpstream:TAG` to push it to dockerhub
