#!/usr/bin/env python

import json
import paho.mqtt.client as mqtt
import re

class ConfigManager:
    def __init__(self, client_id, host, port, username, password):
        self.client_id = client_id
        self.host = host
        self.port = port
        self.username = username
        self.password = password
        self.sequence_number = 0
        self.devices = {}
        self.client = mqtt.Client(client_id=self.client_id)
        self.client.username_pw_set(username=self.username, password=self.password)
        self.client.on_message = self.on_message

        self.client.connect(self.host, self.port)
        self.client.subscribe("/devices/+/state", qos=0)

    def on_message(self, unused_client, unused_userdata, message):
        payload = str(message.payload.decode("utf-8"))
        print(f"Received message '{payload}' on topic '{message.topic}' with Qos {message.qos}")

        match = re.fullmatch('/devices/([^/]+)/state', message.topic)
        if match:
            device_id = match.group(1)
            state = json.loads(payload)
            print(f"state from device {device_id}, state is {state}")
            if not 'sequence_number' in state:
                if not device_id in self.devices:
                    self.sequence_number+=1
                    self.devices[device_id] = {
                    "name": state.get("name", "unknown"),
                    "sequence_number": self.sequence_number,
                }
                self.client.publish(f"/devices/{device_id}/config",
                                    json.dumps(self.devices[device_id]), qos=1, retain=True)
                self.client.publish(f"/wave/devices",
                                    json.dumps(self.devices), qos=0, retain=True)

manager = ConfigManager("configurator-1", "localhost", 1883, "user1", "pass1")
manager.client.loop_forever()
