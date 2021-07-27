#!/bin/bash

play_sound() {
  mosquitto_pub -t /music -u user1 -P pass1 -m "{\"freq\": $1, \"duration\": $2}"
}

while read freq duration; do
  play_sound $freq $duration
done <<EOF
392 200
392 200
392 200
311 400
349 200
349 200
349 200
294 400
EOF
