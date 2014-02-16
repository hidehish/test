#!/bin/bash

# should update kernel to 3.8 for docker after install
# apt-get install linux-image-generic-lts-raring linux-headers-generic-lts-raring


echo 'DOCKER_OPTS="-D -H=unix:///var/run/docker.sock -H=tcp://0.0.0.0:4243"' > /etc/default/docker
apt-get update -y
# apt-get upgrade -y
DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade
apt-get clean
docker -d -r
docker build -t hidehish/docker-node02 /vagrant/docker/
