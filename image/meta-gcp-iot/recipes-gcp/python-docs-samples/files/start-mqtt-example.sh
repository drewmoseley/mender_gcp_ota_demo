#!/bin/sh
#

if [ ! -e /opt/gcp/etc/gcp-config.sh ]; then
    echo "Error. Unable to locate gcp-config.sh."
    exit 1
fi

source /opt/gcp/etc/gcp-config.sh
python /opt/gcp/usr/bin/cloudiot_mqtt_example.py \
       --project_id "${PROJECT_ID}" \
       --registry_id "${REGISTRY_ID}" \
       --device_id "${DEVICE_ID}" \
       --algorithm RS256 \
       --ca_certs /opt/gcp/etc/roots.pem \
       --private_key_file=/var/lib/mender/mender-agent.pem
