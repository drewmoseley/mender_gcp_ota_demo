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
git clone https://github.com/Kcr19/meta-gcp-iotcore.git
source oe-init-build-env
bitbake-layers add-layer ../meta-mender/meta-mender-core
bitbake-layers add-layer ../meta-openembedded/meta-oe
bitbake-layers add-layer ../meta-openembedded/meta-python
bitbake-layers add-layer ../meta-openembedded/meta-multimedia
bitbake-layers add-layer ../meta-openembedded/meta-networking
bitbake-layers add-layer ../meta-raspberrypi
bitbake-layers add-layer ../meta-mender/meta-mender-raspberrypi
bitbake-layers add-layer ../meta-gcp-iotcore
gsutil cp gs://mender-gcp/mender_gcp_scripts/local.conf ./conf/
export FULL_PROJECT=$(gcloud config list project --format "value(core.project)")
export PROJECT="$(echo $FULL_PROJECT | cut -f2 -d ':')"
export REGION='us-central1'
gsutil cp gs://$PROJECT-mender-server/certs/server.crt ../meta-gcp-iotcore/recipes-mender/mender/files/
bitbake rpi-basic-image
export FULL_PROJECT=$(gcloud config list project --format "value(core.project)")
export PROJECT="$(echo $FULL_PROJECT | cut -f2 -d ':')"
export REGION='us-central1' #OPTIONALLY CHANGE THIS
gsutil cp ./tmp/deploy/images/raspberrypi3/rpi-basic-image-raspberrypi3.sdimg gs://$PROJECT-mender-builds
gsutil cp gs://mender-gcp/mender_gcp_scripts/mender-artifacts/local.conf ./conf/
bitbake rpi-basic-image
gsutil cp ./tmp/deploy/images/raspberrypi3/rpi-basic-image-raspberrypi3.mender gs://$PROJECT-mender-builds
