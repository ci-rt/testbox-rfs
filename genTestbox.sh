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
# get own id
ID=$2
VARIANTS=$3

# check for additional variants and add them
if [ "$VARIANTS" != "" ]; then
    VARIANTS=","$VARIANTS
fi

containerUID=`id -u`

echo "========================== running stage: generateTestboxImages ================================="
# run the ELBE build container
docker pull  as-docker-registry.lab.linutronix.de:5000/elbe-builder-initvm:$CONTAINERVERSION
docker run -d --privileged=true  -e container=docker -e containerUID=$containerUID \
--name ELBEVM-$containerUID-$ID -v `pwd`:/home/elbe/build --cap-add SYS_ADMIN --security-opt seccomp=unconfined \
--security-opt apparmor=unconfined --group-add kvm  --device /dev/kvm --device /dev/fuse \
-it as-docker-registry.lab.linutronix.de:5000/elbe-builder-initvm:$CONTAINERVERSION
# wait a while to let the container startup
sleep 3m
# submit the ELBE build
docker exec -u $containerUID ELBEVM-$containerUID-$ID elbe initvm --output /home/elbe/build/ submit \
--variant v2,iotesting$VARIANTS /home/elbe/build/lxtestbox.xml
sleep 1m
docker stop ELBEVM-$containerUID-$ID
docker rm ELBEVM-$containerUID-$ID
