resource "google_pubsub_topic" "default_devicestatus" {
  name = "default-devicestatus"
}

resource "google_pubsub_topic" "default_telemetry" {
  name = "default-telemetry"
}

resource "google_pubsub_topic" "additional_telemetry" {
  name = "additional-telemetry"
}

resource "google_pubsub_subscription" "default_devicestatus" {
  name  = google_pubsub_topic.default_devicestatus.name
  topic = google_pubsub_topic.default_devicestatus.name

  message_retention_duration = "1200s" # 20 minutes
  retain_acked_messages      = true

  ack_deadline_seconds = 20

  expiration_policy {
    ttl = "86400s" # 1 day
  }

  retry_policy {
    minimum_backoff = "10s"
  }

  enable_message_ordering    = false
}

resource "google_pubsub_subscription" "default_telemetry" {
  name  = google_pubsub_topic.default_telemetry.name
  topic = google_pubsub_topic.default_telemetry.name

  message_retention_duration = "1200s" # 20 minutes
  retain_acked_messages      = true

  ack_deadline_seconds = 20

  expiration_policy {
    ttl = "86400s" # 1 day
  }

  retry_policy {
    minimum_backoff = "10s"
  }

  enable_message_ordering    = false
}

resource "google_pubsub_subscription" "additional_telemetry" {
  name  = google_pubsub_topic.additional_telemetry.name
  topic = google_pubsub_topic.additional_telemetry.name

  message_retention_duration = "1200s" # 20 minutes
  retain_acked_messages      = true

  ack_deadline_seconds = 20

  expiration_policy {
    ttl = "86400s" # 1 day
  }

  retry_policy {
    minimum_backoff = "10s"
  }

  enable_message_ordering    = false
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

resource "google_cloudiot_device" "device_dev1" {
  name     = "device-dev1"
  registry = google_cloudiot_registry.test_registry.id

  credentials {
    public_key {
        format = "RSA_PEM"
        key = file("../rsa_public-dev1.pem")
    }
  }

  blocked = false

  log_level = "INFO"

  metadata = {
    test_key_1 = "test_value_1"
  }

  gateway_config {
    gateway_type = "NON_GATEWAY"
  }
}
