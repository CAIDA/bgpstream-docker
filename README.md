# BGPStream Docker files

BGPStream docker images are designed for easy development, and deployment of projects using `libbgpstream` and `pybgpstream` within a dockerized environment. Users can use this image as an base image to develop and deploy their own software based on BGPStream without worrying about the environment setup. Users can also try out useful tools bundled with BGPStream such as `bgpreader` directly using the docker image with a simple one-liner provided users have Docker environment setup.

# Installation

To install the docker image for BGPStream of the latest version, you can run the following command: `docker image pull caida/bgpstream`. Below is the example output.

    $ docker image pull caida/bgpstream
    Using default tag: latest
    latest: Pulling from caida/bgpstream
    000eee12ec04: Already exists
    d518b83f1ada: Pull complete
    277ca7466e29: Pull complete
    14c7538e6bb9: Pull complete
    a36bdf032b0b: Pull complete
    Digest: sha256:3e34f4622b9da17e96305af4e1f9316eba2a7990ac82c45b87cb3f82dc2c64c9
    Status: Downloaded newer image for caida/bgpstream:latest
    docker.io/caida/bgpstream:latest

To install an specific version of the image, please select one tag from the [available tags](https://hub.docker.com/r/caida/bgpstream/tags) first. For example, if you want to check out the version `2.0.0-rc2`. You can run the following command: `docker image pull caida/bgpstream:2.0.0-rc2`.

Afterwards, you can check the available BGPStream images on your setup by docker image list:

    $ docker image list
    REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
    caida/bgpstream     2.0.0-rc2           d7eea000e637        46 hours ago        169MB
    caida/bgpstream     latest              d7eea000e637        46 hours ago        169MB

You can always do docker run caida/bgpstream directly, and it will pull the image first, so you don’t have to do it manually.

# Example Usage

## Run bgpreader directly using this Docker image

You can run the helpful commandline tool `bgpreader` bundled with BGPStream directly from this docker image.

The following command will display all bgp messages collected by `route-views.sfmix` between `1445306400` and `1445306400`.

`docker run caida/bgpstream bgpreader -w 1445306400,1445306402 -c route-views.sfmix`

    $ docker run caida/bgpstream bgpreader -w 1445306400,1445306402 -c route-views.sfmix|head
    R|B|1445306400.000000|routeviews|route-views.sfmix|||V|1445306400
    R|R|1445306400.000000|routeviews|route-views.sfmix|||32354|206.197.187.5|1.0.0.0/24|206.197.187.5|32354 15169|15169|||
    R|R|1445306400.000000|routeviews|route-views.sfmix|||14061|206.197.187.10|1.0.0.0/24|206.197.187.10|14061 15169|15169|||
    R|R|1445306400.000000|routeviews|route-views.sfmix|||32354|206.197.187.5|1.0.4.0/24|206.197.187.5|32354 4826 38803 56203|56203|||
    R|R|1445306400.000000|routeviews|route-views.sfmix|||14061|206.197.187.10|1.0.4.0/24|206.197.187.12|14061 6939 4826 38803 56203|56203|||
    R|R|1445306400.000000|routeviews|route-views.sfmix|||32354|206.197.187.5|1.0.5.0/24|206.197.187.5|32354 4826 38803 56203|56203|||
    R|R|1445306400.000000|routeviews|route-views.sfmix|||14061|206.197.187.10|1.0.5.0/24|206.197.187.12|14061 6939 4826 38803 56203|56203|||
    R|R|1445306400.000000|routeviews|route-views.sfmix|||32354|206.197.187.5|1.0.6.0/24|206.197.187.5|32354 4826 38803 56203 56203 56203|56203|||
    R|R|1445306400.000000|routeviews|route-views.sfmix|||14061|206.197.187.10|1.0.6.0/24|206.197.187.12|14061 6939 4826 38803 56203 56203 56203|56203|||
    R|R|1445306400.000000|routeviews|route-views.sfmix|||32354|206.197.187.5|1.0.7.0/24|206.197.187.5|32354 6939 4637 1221 38803|38803|||

For more usage examples and tutorials for `bgpreader`, please check out the tutorial website at [https://bgpstream.caida.org/docs/tutorials/bgpreader](https://bgpstream.caida.org/docs/tutorials/bgpreader)

## Build/test BGPStream application within Docker

You can also develop and test applications that use BGPStream within the docker environment. Below is an example using the `caida/bgpstream` image as base image to test `pybgpstream` code using the extended image.

First, here is a pybgpstream example code (for more examples, check out the official [tutorial page](https://bgpstream.caida.org/docs/tutorials/pybgpstream)):

    #!/usr/bin/env python
    
    import pybgpstream
    stream = pybgpstream.BGPStream(
        from_time="2017-07-07 00:00:00", until_time="2017-07-07 00:10:00 UTC",
        collectors=["route-views.sg", "route-views.eqix"],
        record_type="updates",
        filter="peer 11666 and prefix more 210.180.0.0/16"
    )
    
    for elem in stream:
        # record fields can be accessed directly from elem
        # e.g. elem.time
        # or via elem.record
        # e.g. elem.record.time
        print(elem)

To test this script, we are going to create a new docker image and copy this script into the image to run.

    FROM caida/bgpstream:latest
    LABEL maintainer="Mingwei Zhang <mingwei@caida.org>"
    
    WORKDIR /tmp
    COPY pybgpstream-print.py pybgpstream-print.py
    
    ENTRYPOINT ["/usr/bin/python3"]
    CMD ["pybgpstream-print.py"]

Make sure to name the python script as `pybgpstream-print.py` or any name that corresponds to the first parameter of the `COPY` command in the Dockerfile. Also name the docker image as `Dockerfile.pybgpstream` and tag the image as `pybgpstream`. Change them as you wish.

At this point, we have a docker file and a python script, we and build and run this image now.

    $ docker build -t pybgpstream -f Dockerfile.pybgpstream ./
    $ docker run pybgpstream
    update|A|1499385779.000000|routeviews|route-views.eqix|None|None|11666|206.126.236.24|210.180.224.0/19|206.126.236.24|11666 3356 3786|3356:2003 11666:1002 3356:666 3356:3 3356:22 11666:1000 3786:0 3356:575 3356:86|None|None
    update|A|1499385779.000000|routeviews|route-views.eqix|None|None|11666|206.126.236.24|210.180.0.0/19|206.126.236.24|11666 3356 3786|3356:2003 11666:1002 3356:666 3356:3 3356:22 11666:1000 3786:0 3356:575 3356:86|None|None
    update|A|1499385788.000000|routeviews|route-views.eqix|None|None|11666|206.126.236.24|210.180.64.0/19|206.126.236.24|11666 6939 4766 4766|11666:2000 11666:2001|None|None
    update|A|1499385833.000000|routeviews|route-views.eqix|None|None|11666|206.126.236.24|210.180.96.0/19|206.126.236.24|11666 9318|11666:2000 11666:2008|None|None
    update|A|1499385851.000000|routeviews|route-views.eqix|None|None|11666|206.126.236.24|210.180.32.0/20|206.126.236.24|11666 3356 3786 4663 4663 4663 4663 4663|11666:1002 3356:666 3356:3 3356:2011 3356:22 11666:1000 3786:11 3356:575 3356:86|None|None
    update|A|1499385851.000000|routeviews|route-views.eqix|None|None|11666|206.126.236.24|210.180.48.0/20|206.126.236.24|11666 3356 3786 4663 4663 4663 4663 4663|11666:1002 3356:666 3356:3 3356:2011 3356:22 11666:1000 3786:11 3356:575 3356:86|None|None
    update|A|1499385852.000000|routeviews|route-views.eqix|None|None|11666|206.126.236.24|210.180.32.0/19|206.126.236.24|11666 9318 4663 4663 4663 4663 4663|11666:2000 11666:2008|None|None
    update|A|1499385908.000000|routeviews|route-views.eqix|None|None|11666|206.126.236.24|210.180.126.0/24|206.126.236.24|11666 6939 4766 45399|11666:2000 11666:2001|None|None
    update|A|1499386004.000000|routeviews|route-views.eqix|None|None|11666|206.126.236.24|210.180.61.0/24|206.126.236.24|11666 3356 3786 4663 4663|11666:1002 3356:666 3356:3 3356:2011 3356:22 11666:1000 3786:11 3356:575 3356:86|None|None
    update|A|1499386007.000000|routeviews|route-views.eqix|None|None|11666|206.126.236.24|210.180.128.0/18|206.126.236.24|11666 6939 4766 9706|11666:2000 11666:2001|None|None
    update|A|1499386007.000000|routeviews|route-views.eqix|None|None|11666|206.126.236.24|210.180.192.0/19|206.126.236.24|11666 6939 4766 9706|11666:2000 11666:2001|None|None

# Useful Links

- [BGPStream image on Docker Hub](https://hub.docker.com/r/caida/bgpstream)
- [BGPStream Docker image source on GitHub](https://github.com/CAIDA/bgpstream-docker)
