#!/bin/sh
#

export PROJECT_ID="$(echo $FULL_PROJECT | cut -f2 -d ':')"
export REGION_ID='us-central1'

export REGISTRY_ID='mender-demo'
export DEVICE_ID='mender_ota_rasp3'

python cloudiot_mqtt_example.py \
       --project_id "${PROJECT_ID}" \
       --registry_id "${REGISTRY_ID}" \
       --device_id "${DEVICE_ID}" \
       --algorithm RS256 \
       --private_key_file=/var/lib/mender/mender-agent.pem
