locals { 
  vm_name = format(%{metric.labels.vm_name}", "$")
  project_name = regex("hsbc-[a-zA-Z0-9-]+", path.cmd)
  env  = regex("hsbc-[0-9]+-[a-zA-Z0-9-]+-([a-z]+)", local.project_name)[0]
}

resource "google_logging_metric" "application-logs" {
  name = "${var.application}-logs-metric"
  project = local.project_name
  filter = "${var.metriclogfilter}
  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
    labels {
      key     = var.label1_1
      value_type  = "STRING"
      description  = "${var.application}"
  }
  labels {
  key  = var.label2_1
  value_type  = "STRINg"
  description = "The error message for alert"
  }
 }
 label_extractors = {
  "${var.label1_1}"   = "${var.label1_value}"
  "${var.label2_1}"   = "${var.label2_value}"
 }
}

resource "google_logging_metric" "application-logs1" {
  count = var.create_second_metric ? 1 : 0
  name = "${var.application}-logs-metric1"
  project = local.project_name
  filter = "${var.metriclogfilter}
  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
    labels {
      key     = var.label1_1
      value_type  = "STRING"
      description  = "${var.application}"
  }
labels {
  key  = var.label2_1
  value_type  = "STRINg"
  description = "The error message for alert"
  }
 }
 label_extractors = {
  "${var.label1_1}"   = "${var.label1_value}"
  "${var.label2_1}"   = "${var.label2_value}"
 }
}

resource "google_monitoring_alert_policy" "application-alert" {
  display_name = "${var.application}-error-alert
  project = local.project_name
  combiner = "OR"
  notification_channels = google_monitoring_notification_channel.email.*.id
  enabled = var.enabled_policy
  
  conditions {
   display_name = "${var.application}-error-alert"
   condition_threshold {
     filter   = "${var.alertfilter}"
     duration = var.duration
     comparison = "COMPARISON_GT"
     threshold_value = 0
     aggregations {
       alignment_period  = var.alignment_period
       per_series_aligner = "${var.series_aligner}"
    }
    trigger {
      count = 1
    }
   }
  }
  
  dynamic conditions {
   for_each = var.create_second_metric ? [1] : []
   content {
     display_name = "${var.application}-error-alert"
     condition_threshold {
      filter   = "${var.alertfilter}"
      duration = var.duration
      comparison = "COMPARISON_GT"
      threshold_value = 0
      aggregations {
       alignment_period  = var.alignment_period
       per_series_aligner = "${var.series_aligner}"
    }
    trigger {
      count = 1
    }
   }
  }
}

documentation {
   content = <<EOT
key=${var.appalertapi_key}
Severity=WARNING
text=SMTP Alert App: ${var.application}, Project:${var.project_name}, Resource Group: ${google_monitoring_group.basic.display_name}, Metric Name: ${google_logging_metric.application-logs.name}
Stackdriver throwing an Error for ${var.application} in ${var.project_name}
application=${var.appalertapi_application}
EOT
 }
}

resource "google_monitoring_notification_channel" "email" {
 count   = length(var.emailgroup)
 display_name = "Email alerts for ${var.application} on ${element(var.emailgroup, count.index)}"
 type  = "email"
 project  = local_project_name
 labels {
   email_address = element(var.emailgroup, count.index)
  }
 }
 
