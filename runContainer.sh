#!/bin/sh

# Enable x11 forwarding
xhost +

# Remove old stopped containers
sudo docker container prune -f

# This preparation of a self extracting executable file that is similar to
# .exe file in windows. For the implementation of this code please visit
# http://wiki.ros.org/action/login/docker/Tutorials/Hardware%20Acceleration#nvidia-docker2 which explains
# hardware acceleration on docker containers using Nvidia-docker2

echo "Killing existing containers"
sudo docker kill cartographer-dev

echo "Preparing Xauthority data..."
XAUTH=/tmp/.docker.xauth
xauth_list=$(xauth nlist :0 | tail -n 1 | sed -e 's/^..../ffff/')
if [ ! -f $XAUTH ]; then
    if [ ! -z "$xauth_list" ]; then
        echo $xauth_list | xauth -f $XAUTH nmerge -
    else
        touch $XAUTH
    fi
    chmod a+r $XAUTH
fi

echo "Running the GazeboSimulationContainer"
docker run -it \
    --name="cartographer-dev" \
    --env="DISPLAY=$DISPLAY" \
    --env="QT_X11_NO_MITSHM=1" \
    --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
    --env="XAUTHORITY=$XAUTH" \
    --volume="$XAUTH:$XAUTH" \
    --net="host" \
    --ipc=host \
    --privileged \
    --runtime=nvidia \
    ros-dev:latest \
    bash
echo "Done."