resource "google_pubsub_topic" "topic" {
 name   = var.topic
 project  = var.project
 kms_key_name  = var.cmek_key
 message_storage_policy {
 allowed_persistence_regions = [var.region]
 }
}

resource "google_pubsub_subscription" "subscription" {
project  = var.project
name = var.subscription
topic = google_pubsub_topic.topic.name
}

resource "google_storage_notification" "notification" {
bucket = var.bucket
payload_format = var.payloadformat
topic = google_pubsub_topic.topic.name
object_name_prefix = var.prefix

depends_on = [google_pubsub_topic_iam_binding.binding]
}

//Enabe notifications by giving the correct IAM permission to the unique service account

data "google_storage_project_service_account" "gcs_account" {
project = var.project
}

resource "google_pubsub_topic_iam_binding" "binding" {
topic = "gogle_pubsub_topic.topic.name
role  = "roles/pubsub.publisher"
members = [serviceAccount:${data.google_storage_project_service_account.gcs_account.email_address}"]
}

resource "google_pubsub_topic_iam_binding" "binding" {
subscription = "gogle_pubsub_subscription.subscription.name
role  = "roles/pubsub.subscriber"
members = [serviceAccount:${data.google_storage_project_service_account.gcs_account.email_address}"]
}
