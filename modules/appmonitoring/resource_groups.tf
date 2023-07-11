 resource "google_monitoring_group" "basic" {
   display_name = "${var.application}-resource-group"
   project  = var.project_name
   filter   = "resource.metadata.tag.application:${var.application}"
 }
