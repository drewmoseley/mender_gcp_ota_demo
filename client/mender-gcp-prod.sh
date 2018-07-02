#!/bin/sh
#

git clone -b 1.5.0 https://github.com/mendersoftware/integration mender-server
cd mender-server
git checkout -b my-production-setup
cp -a template production
cd production
gsutil cp gs://mender-gcp/mender_gcp_scripts/prod.yml ./
sed -i -e 's#/template/#/production/#g' prod.yml
git config --global user.email "test@example.com"
git config --global user.name test.mender "Test"
git add .
git commit -m 'production: initial template'
./run pull
CERT_API_CN=mender.gcpotademo.com CERT_STORAGE_CN=gcs.mender.gcpotademo.com ../keygen
git add keys-generated
git commit -m 'production: adding generated keys and certificates'
docker volume create --name=mender-artifacts
docker volume create --name=mender-deployments-db
docker volume create --name=mender-useradm-db
docker volume create --name=mender-inventory-db
docker volume create --name=mender-deviceadm-db
docker volume create --name=mender-deviceauth-db
docker volume create --name=mender-elasticsearch-db
docker volume create --name=mender-redis-db
docker volume inspect --format '{{.Mountpoint}}' mender-artifacts
git add prod.yml
git commit -m 'production: final configuration'
./run up -d
sudo ./run exec mender-useradm /usr/bin/useradm create-user --username=mender@example.com --password=Mender@2017
export FULL_PROJECT=$(gcloud config list project --format "value(core.project)")
export PROJECT="$(echo $FULL_PROJECT | cut -f2 -d ':')"
export REGION='us-central1'
gsutil cp keys-generated/certs/server.crt gs://$PROJECT-mender-server/certs/
