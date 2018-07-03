#!/bin/sh
#

sudo apt-get update
sudo apt-get -y install gawk wget git-core diffstat unzip texinfo gcc-multilib \
     build-essential chrpath socat cpio python python3 python3-pip python3-pexpect \
     xz-utils debianutils iputils-ping libsdl1.2-dev xterm
git clone -b rocko git://git.yoctoproject.org/poky
cd poky
git clone -b rocko git://github.com/mendersoftware/meta-mender
git clone -b rocko git://git.openembedded.org/openembedded-core
git clone -b rocko git://git.openembedded.org/meta-openembedded
git clone -b rocko https://github.com/agherzan/meta-raspberrypi
git clone https://github.com/Kcr19/meta-gcp-iot.git
source ./oe-init-build-env
bitbake-layers add-layer -F ../meta-mender/meta-mender-core
bitbake-layers add-layer -F ../meta-openembedded/meta-oe
bitbake-layers add-layer -F ../meta-openembedded/meta-python
bitbake-layers add-layer -F ../meta-openembedded/meta-multimedia
bitbake-layers add-layer -F ../meta-openembedded/meta-networking
bitbake-layers add-layer -F ../meta-raspberrypi
bitbake-layers add-layer -F ../meta-mender/meta-mender-raspberrypi
bitbake-layers add-layer -F ../meta-gcp-iot
export FULL_PROJECT=$(gcloud config list project --format "value(core.project)")
export PROJECT="$(echo $FULL_PROJECT | cut -f2 -d ':')"
export REGION='us-central1'
export MACHINE='raspberrypi3'
gsutil cp gs://$PROJECT-mender-server/certs/server.crt ../meta-gcp-iot/recipes-mender/mender/files/
bitbake gcp-mender-demo-image
gsutil cp ./tmp/deploy/images/raspberrypi3/rpi-basic-image-raspberrypi3.sdimg gs://$PROJECT-mender-builds
gsutil cp gs://mender-gcp/mender_gcp_scripts/mender-artifacts/local.conf ./conf/
bitbake gcp-mender-demo-image
gsutil cp ./tmp/deploy/images/raspberrypi3/rpi-basic-image-raspberrypi3.mender gs://$PROJECT-mender-builds
