data "google_compute_zones" "available" {
 project = var.project_name
 region  = var.region
 }

locals {
  gce_prefix = "gce-${substr(var.region,0,2)}-${regex("[a-z]+-([a-zA-z0-9]+)", var.region)[0]}-$(substr(var.env,0 ,1)}-$(var.application}"
  gcn_prefix = "gce-${substr(var.region,0,2)}-${regex("[a-z]+-([a-zA-z0-9]+)", var.region)[0]}-$(substr(var.env,0 ,1)}-$(var.application}"
}

# template file for adding ssh public keys to VM metadata
data "template_file" "sshkey" {
   count = var.enable_sshkey ? 1 : 0
   template = file("../../files/ssh-keys.conf")
 }
 
 resource "google_compute_instance" "vm1" {
  name_prefix = "${local.gce_prefix}-${var.application}"
  description = "This template is used to create app server instances."
  project     = var.project_name
  machine_type         = var.machine_type
  tags                 = var.tags
  deletion_protection  = false
  allow_stopping_for_update = true

  boot_ disk {
    source     = google.compute_disk.boot_disk.self_link
    auto_delete  = true
    kms_key_self_link = var.cmek_key
  }


  service_account =   {
    email = "${var.application}@${var.project_name}.iam.gserviceaccount.com"
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  } 
  
    network_interface {
      subnetwork = var.subnetwork
      network_ip = var.enable_network_ip ? var.vm_ip_address : null
  }

   dynamic network_interface {
    for_each = var.enable_dualnic ? [1] : []
    content {
        subnetwork = var.subnetwork1
        network_ip = var.enable_network_ip_2 ? var.vm_ip_address_2 : null
    }
  }
dynamic attached_disk {
      for_each = var.enable_attached_disk ? [1] : []
       content {
           source = length(google_compute_disk.attached-disk) > 0 ? google_compute_disk.attached-disk[0].self_link : null
           mode  = "READ_WRITE"
           kms_key_self_link = var.cmek_key           }
  }

  metadata = var.metadata

  labels = {
      terraformed =  true
      project     = var.project_name
      app         = var.application
      environment = var.environment
  } 


   lifecycle = { 
      create_before_destroy = true
   }
 }
 
 resource "google_compute__disk" "boot_disk" {
  project                   = var.project_name  
  name                      = "${local.gce_prefix}-boot-disk"
  snapshot                  = var.snapshot_boot
  type                      = var.attached_disk_type
  size                      = var.attached_disk_size
  region                    = var.region
  zones                     = data.google_compute_zones.available.names[0]

    disk_encryption_key {
    kms_key_self_link = var.cmek_key
  }

  labels = {
      terraformed = "true"
      project     = var.project_name
      name        = "${local.gce_prefix}-attached-disk"
      app         = var.application
      environment = var.env
  }
  }
  
  resource "google_compute_region_disk" "attached-disk" {
  count                     = var.enable_attached_disk ? 1 : 0
  provider                  = google-beta
  project                   = var.project_name  
  name                      = "${local.gce_prefix}-attached-disk"
  snapshot                  = var.snapshot_attached
  type                      = var.attached_disk_type
  size                      = var.attached_disk_size
  region                    = var.region
  zones                     = data.google_compute_zones.available.names[0]

    disk_encryption_key {
    kms_key_self_link = var.cmek_key
  }

  labels = {
      terraformed = "true"
      project     = var.project_name
      name        = "${local.gce_prefix}-attached-disk"
      app         = var.application
      environment = var.env
  }
  }
  
  resource "google_compute_instance_group" "instance_group" {
  count              = var.enable_instance_group ? 1 : 0
  name               = "${local.gce_prefix}-unmig"
  project            = var.project_name
  instances          = [google_compute_instance.vm1.self_link]
  description        = "${var.application} compute VM unmanaged instance group"
  zones              = data.google_compute_zones.available.names[0]
    lifecycle {
    create_before_destroy = true
  }
  }
  
  resource "google_compute_address" "static_ip" {
  count = var.enable_static_ip ? 1 : 0
  name = "${local.gcn_prefix}-address"
  project = var.project_name
  address = var.enable_address ? var.address : null
  address_type  = "INTERNAL"
  #region     = var.region

    lifecycle {
    prevent_destroy = true
  }
}

// Forwarding rule for Internal Load Balancing
resource "google_compute_forwarding_rule" "fw_rule" {
  count                 = var.enable_forwarding_rule ? 1 : 0
  project               = var.project_name  
  name                  = "${local.gcn_prefix}-forwarding-rule"
  load_balancing_scheme = "INTERNAL"
  ip_address            = var.enable_static_ip ? google_compute_address.static_ip[0].address : var.ip_address
  ports                 = var.ports
  subnetwork            = var.subnetwork
  backend_service       = var.enable_backend_service ? google_compute_region_backend_service.backend[0].self_link : null
}


resource "google_compute_region_backend_service" "backend" {
  count                 = var.enable_backend_service ? 1 : 0
  project               = var.project_name  
  name                  = "${local.gcn_prefix}-backend-service"
  region                = var.region
  health_checks         = var.enable_health_check ? [google_compute_health_check.health-chec.self_link] : null

  backend {
      group = var.enable_health_check ? google_compute_instance_group_.instance_group[0].self_link : null
  }
}
resource "google_compute_health_check" "health-check" {
  count                 = var.enable_health_check ? 1 : 0
  project               = var.project_name  
  name                  = var.enable_health_check ? "${local.gce_prefix}-https-health_check" : "${local.gce_prefix}-health-check
  check_interval_sec    = var.hc_interval
  timeout_sec           = var.hc_timeout
  healthy_threshold     = var.hc_healthy_threshold
  unhealthy_threshold   = var.hc_unhealthy_threshold
tcp_health_check {
       port = var.hc_port
  }
}
