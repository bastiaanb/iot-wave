import machine
#import esp32
import network
from umqtt.simple import MQTTClient
from machine import Pin, PWM
import time
import ujson

#wlan = network.WLAN(network.STA_IF)
#ubinascii.hexlify(wan.config('mac'))
MQTT_SERVER = '172.16.206.125'
MQTT_CLIENT_ID = "user1"
MQTT_USER = "user1"
MQTT_PASSWORD = "pass1"
MQTT_DEVICE_ID = "device-123"

MQTT_TOPIC_MUSIC = '/music'
MQTT_TOPIC_CHAT = '/chat/general'
MQTT_TOPIC_CONFIG = '/devices/{}/config'.format(MQTT_DEVICE_ID)
MQTT_TOPIC_COMMANDS = '/devices/{}/commands'.format(MQTT_DEVICE_ID)

buzzer = PWM(Pin(15), freq=440, duty=1023)

def on_message(topic_bytes, message_bytes):
    topic = topic_bytes.decode('utf-8')
    message = ujson.loads(message_bytes.decode('utf-8'))
    print((topic,message))
    if topic == MQTT_TOPIC_MUSIC:
        freq = message.get('freq', 0)
        duration = message.get('duration', 1)
        print("music {}".format(freq))
        buzzer.freq(freq)
        buzzer.duty(100)
        time.sleep_ms(duration)
        buzzer.duty(1023)
    elif topic == MQTT_TOPIC_CHAT:
        msg = message.get('msg')
        frm = message.get('from')
        print("message {}: {}".format(frm, msg))  
    elif topic == MQTT_TOPIC_CONFIG:
        print('config {}'.format(message.get('sequence_number')))
    # elif topic.starts_with(MQTT_TOPIC_COMMANDS):
    #     print('command')
    else:
        print('unknown topic')

def get_mqtt_client():
    client_id = "user1"
    client = MQTTClient(MQTT_CLIENT_ID.encode('utf-8'),
                        server=MQTT_SERVER,
                        port=1883,
                        user=MQTT_USER.encode('utf-8'),
                        password=MQTT_PASSWORD.encode('utf-8'),
                        ssl=False)
    client.set_callback(on_message)
    client.connect()
    client.subscribe(MQTT_TOPIC_MUSIC, 0)
    client.subscribe(MQTT_TOPIC_CHAT, 0)
    client.subscribe(MQTT_TOPIC_CONFIG, 1)
    client.subscribe('{}/#'.format(MQTT_TOPIC_COMMANDS), 1)
    return client


client = get_mqtt_client()
while True:
    client.wait_msg()
