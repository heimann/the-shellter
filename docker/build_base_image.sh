#!/bin/bash

# Ensure user passed enough args
if [ "$#" -ne 1 ]; then
  IMG_TYPE="dev"
else
  IMG_TYPE=$1
fi

IMG_NAME="theshellter"
IMG="$IMG_NAME:$IMG_TYPE"

echo "=================BUILDING DOCKERFILE================="
echo "docker build . -t $IMG"
echo ""
docker build . -t $IMG
CONTAINER_ID=`docker run -itd $IMG`

echo ""
echo "=================BUILDING CONTAINER=================="
echo "docker exec -itd $CONTAINER_ID sh /tmp/post_launch.sh theshellter"
echo ""
docker exec -it $CONTAINER_ID sh /tmp/post_launch.sh theshellter

echo ""
echo "=================COMMITING CONTAINER================="
echo "docker commit $CONTAINER_ID $IMG"
echo ""
docker commit $CONTAINER_ID $IMG
