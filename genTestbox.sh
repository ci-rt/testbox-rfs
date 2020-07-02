#!/bin/bash -x
# build the Testbox Images

set -e
trap 'catch $? $LINENO' EXIT

catch() {
    if [ "$1" != "0" ]; then
    # error handling goes here
    echo "Error $1 occurred on $2"
  fi
}

CONTAINERVERSION=$1
containerUID=`id -u`

echo "========================== running stage: generateTestboxImages ================================="
# run the ELBE build container
docker pull  as-docker-registry.lab.linutronix.de:5000/elbe-builder-initvm:$CONTAINERVERSION
docker run -d --privileged=true  -e container=docker -e containerUID=$containerUID \
--name ELBEVM-$containerUID -v `pwd`:/home/elbe/build --cap-add SYS_ADMIN --security-opt seccomp=unconfined \
--security-opt apparmor=unconfined --group-add kvm  --device /dev/kvm --device /dev/fuse \
-it as-docker-registry.lab.linutronix.de:5000/elbe-builder-initvm:$CONTAINERVERSION
# wait a while to let the container startup
sleep 3m
# submit the ELBE build
docker exec -u $containerUID ELBEVM-$containerUID elbe initvm --output /home/elbe/build/ submit \
--variant v2,io-testing /home/elbe/build/lxtestbox.xml
sleep 1m
docker stop ELBEVM-$containerUID
docker rm ELBEVM-$containerUID
