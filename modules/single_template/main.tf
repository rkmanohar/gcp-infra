data "google_compute_zones" "available" {
 project = var.project_name
 region  = var.region
 }

locals {
  gce_prefix = "gce-${substr(var.region,0,2)}-${regex("[a-z]+-([a-zA-z0-9]+)", var.region)[0]}-$(substr(var.env,0 ,1)}-$(var.application}"
  gcn_prefix = "gce-${substr(var.region,0,2)}-${regex("[a-z]+-([a-zA-z0-9]+)", var.region)[0]}-$(substr(var.env,0 ,1)}-$(var.application}"

}
 resource "google_compute_instance_template" "linux" {
  count       = var.linux ? 1 : 0   
  name_prefix = "${local.gce_prefix}-"
  description = "This template is used to create app server instances."
  project     = var.project_name
  instance_description = "description assigned to instances"
  machine_type         = var.machine_type
  tags                 = var.tags

   network_interface =  { 
    subnetwork = var.subnetwork
}
 
 // Create a new boot disk from an image
  disk {
    device_name  = "${local.gce_prefix}-boot-disk"
    source_image = var.image
    disk_size_gb = var.disk_size
    auto_delete  = true
    boot         = true
    disk_encryption_key {
    kms_key_self_link = var.cmek_key
  }
  labels = {
      terraformed =  true
      project     = var.project_name
      name        = "${local.gce_prefix}-boot-disk"
      app         = var.application
      environment = var.environment
  }  
  }
 labels = {
      terraformed =  true
      project     = var.project_name
      app         = var.application
      environment = var.environment
  }
   
    service_account =   {
    email = "${var.application}@${var.project_name}.iam.gserviceaccount.com"
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
  
 }

resource "google_compute_instance_template" "windows" {
  count       = var.windows ? 1 : 0   
  name_prefix = "${local.gce_prefix}-"
  description = "This template is used to create app server instances."
  project     = var.project_name
  instance_description = "description assigned to instances"
  machine_type         = var.machine_type
  tags                 = var.tags

  disk {
    device_name  = "${local.gce_prefix}-boot-disk"
    source_image = var.image
    disk_size_gb = var.disk_size
    auto_delete  = true
    boot         = true
    disk_encryption_key {
    kms_key_self_link = var.cmek_key
  }
  labels = {
      terraformed =  true
      project     = var.project_name
      name        = "${local.gce_prefix}-boot-disk"
      app         = var.application
      environment = var.environment
  }  
  }
   labels = {
      terraformed =  true
      project     = var.project_name
      app         = var.application
      environment = var.environment
  }
  
     service_account =   {
    email = "${var.application}@${var.project_name}.iam.gserviceaccount.com"
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
  
 }
