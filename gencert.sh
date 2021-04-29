#!/bin/bash

# https://cloud.google.com/iot/docs/how-tos/credentials/keys
ID=${1:-dev1}

openssl req -x509 -newkey rsa:2048 -keyout rsa_private-$ID.pem -nodes -out cert-$ID.pem -subj "/CN=$ID"
openssl rsa -in rsa_private-$ID.pem -pubout -out rsa_public-$ID.pem
