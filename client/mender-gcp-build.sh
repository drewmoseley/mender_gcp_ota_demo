#!/bin/bash
#

sudo apt-get update
sudo apt-get -y install gawk wget git-core diffstat unzip texinfo gcc-multilib \
     build-essential chrpath socat cpio python python3 python3-pip python3-pexpect \
     xz-utils debianutils iputils-ping libsdl1.2-dev xterm
[ -d poky ] || git clone -b rocko git://git.yoctoproject.org/poky
cd poky
[ -d meta-mender ] || git clone -b rocko git://github.com/mendersoftware/meta-mender
[ -d meta-openembedded ] || git clone -b rocko git://git.openembedded.org/meta-openembedded
[ -d meta-raspberrypi ] || git clone -b rocko https://github.com/agherzan/meta-raspberrypi
[ -d meta-gcp-iot ] || git clone https://github.com/Kcr19/meta-gcp-iot.git
source ./oe-init-build-env
cat > conf/auto.conf <<-	EOF
	MACHINE="raspberrypi3"
	
	# Switch to systemd - required for Mender
	DISTRO_FEATURES_append += " systemd"
	VIRTUAL-RUNTIME_init_manager = "systemd"
	DISTRO_FEATURES_BACKFILL_CONSIDERED = "sysvinit"
	VIRTUAL-RUNTIME_initscripts = ""
	
	# Configure Mender
	INHERIT += "mender-full"
	MENDER_ARTIFACT_NAME = "release-1"
	MENDER_SERVER_URL = "https://mender.gcpotademo.com"
	IMAGE_INSTALL_append = " kernel-image kernel-devicetree"
	
	# RPI specific additions for Mender
	RPI_USE_U_BOOT = "1"
	MENDER_PARTITION_ALIGNMENT_KB = "4096"
	MENDER_BOOT_PART_SIZE_MB = "40"
	MENDER_STORAGE_TOTAL_SIZE_MB_rpi = "4000"
	MENDER_DATA_PART_SIZE_MB_rpi = "1000"
	##IMAGE_ROOTFS_MAXSIZE_rpi ?= "20000000"
	IMAGE_FSTYPES_remove += " rpi-sdimg ext3"
	SDIMG_ROOTFS_TYPE = "ext4"
	
	PACKAGE_CLASSES = "package_ipk"
	INHERIT += "rm_work"
EOF
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
gsutil cp gs://$PROJECT-mender-server/certs/server.crt ../meta-gcp-iot/recipes-mender/mender/files/
bitbake gcp-mender-demo-image
gsutil cp ./tmp/deploy/images/raspberrypi3/rpi-basic-image-raspberrypi3.sdimg gs://$PROJECT-mender-builds
cat >> conf/auto.conf <<-	EOF
	MENDER_ARTIFACT_NAME = "release-2"
EOF
bitbake gcp-mender-demo-image
gsutil cp ./tmp/deploy/images/raspberrypi3/rpi-basic-image-raspberrypi3.mender gs://$PROJECT-mender-builds
