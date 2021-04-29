#!/bin/bash

./cloudiot_mqtt_example.py \
  --project_id global-datacenter \
  --cloud_region europe-west1 \
  --registry_id cloudiot-registry \
  --mqtt_bridge_hostname mqtt.googleapis.com \
  --mqtt_bridge_port 8883 \
  --ca_certs ../roots.pem \
  --device_id device-dev1 \
  --private_key_file ../rsa_private-dev1.pem \
  --algorithm RS256 \
  device_demo
