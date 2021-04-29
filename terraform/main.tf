// resource "google_cloudiot_registry" "iot_test1" {
//   name     = "iot-test1"
// }
//
// resource "google_pubsub_topic" "iot_test1" {
//   name = "iot-test1"
// }
//
// resource "google_pubsub_subscription" "iot_test1" {
//   name  = "iot-test1-subscription"
//   topic = google_pubsub_topic.iot_test1.name
//
//   labels = {
//     foo = "bar"
//   }
//
//   # 20 minutes
//   message_retention_duration = "1200s"
//   retain_acked_messages      = true
//
//   ack_deadline_seconds = 20
//
//   expiration_policy {
//     ttl = "300000.5s"
//   }
//   retry_policy {
//     minimum_backoff = "10s"
//   }
//
//   enable_message_ordering    = false
// }
//

resource "google_pubsub_topic" "default_devicestatus" {
  name = "default-devicestatus"
}

resource "google_pubsub_topic" "default_telemetry" {
  name = "default-telemetry"
}

resource "google_pubsub_topic" "additional_telemetry" {
  name = "additional-telemetry"
}

resource "google_cloudiot_registry" "test_registry" {
  name     = "cloudiot-registry"

  event_notification_configs {
    pubsub_topic_name = google_pubsub_topic.additional_telemetry.id
    subfolder_matches = "test/path"
  }

  event_notification_configs {
    pubsub_topic_name = google_pubsub_topic.default_telemetry.id
    subfolder_matches = ""
  }

  state_notification_config = {
    pubsub_topic_name = google_pubsub_topic.default_devicestatus.id
  }

  mqtt_config = {
    mqtt_enabled_state = "MQTT_ENABLED"
  }

  http_config = {
    http_enabled_state = "HTTP_ENABLED"
  }

  log_level = "INFO"

  // credentials {
  //   public_key_certificate = {
  //     format      = "X509_CERTIFICATE_PEM"
  //     certificate = file("test-fixtures/rsa_cert.pem")
  //   }
  // }
}
