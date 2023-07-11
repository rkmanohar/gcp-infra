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
    network_ip = var.enable_network_ip ? var.vm_ip_address : null
  }

  dynamic network_interface {
    for_each = var.enable_dualnic ? [1] : []
    content {
        subnetwork = var.subnetwork1
    }
  }

   dynamic network_interface {
    for_each = var.enable_dualnic_2 ? [1] : []
    content {
        subnetwork = var.subnetwork2
    }
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

  dynamic disk {
      for_each = var.enable_attached_disk ? [1] : []
       content {
           source = length(google_compute_region_disk.attached-disk) > 0 ? google_compute_region_disk.attached-disk[0].self_link : null
           auto_delete = false
           disk_encryption_key {
             kms_key_self_link = var.cmek_key    
           }
       }
  }

  metadata = var.metadata

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

   lifecycle = { 
      create_before_destroy = true
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

  dynamic disk {
      for_each = var.enable_attached_disk ? [1] : []
       content {
           source = length(google_compute_region_disk.attached-disk) > 0 ? google_compute_region_disk.attached-disk[0].self_link : null
           auto_delete = false
           disk_encryption_key {
             kms_key_self_link = var.cmek_key    
           }
       }
  }

  metadata = var.metadata

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

   lifecycle = { 
      create_before_destroy = true
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
  replica_zones             = slice(data.google_compute_zones.available.names, 0, 2)

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

  resource "google_compute_region_instance_group_manager" "mig" {
  name               = "${local.gce_prefix}-mig"
  project            = var.project_name
  region             = var.region
  description        = "${var.application} compute VM managed instance group"
  description_policy_zones = slice(data.google_compute_zones.available.names, 0, 2)

  update_policy {
      minimal_action = "RESTART"
      type     = "OPPORTUNISTIC"
      instance_redistribution_type = "NONE"
      max_unavailable_fixed = 2
  }
  
  base_instance_name = "${local.gce_prefix}-instance"
  version {
  instance_template  = var.linux ? google_compute_instance_template.linux[0].self_link : google_compute_instance_template.windows[0].self_link
  }

  target_pools = var.target_pools
  target_size  = var.target_size

  lifecycle {
    create_before_destroy = true
  }
  named_port {
      name = var.service_port_name
      port = var.service.port
  }
}

resource "google_compute_address" "static_ip" {
  count = var.enable_static_ip ? 1 : 0
  name = "${local.gcn_prefix}-address"
  project = var.project_name
  subnetwork = var.subnetwork
  address_type  = "INTERNAL"
  region     = var.region

    lifecycle {
    prevent_destroy = true
  }
}

resource "google_compute_region_autoscaler" "autoscaler" {
  count      = var.enable_autoscaling ? 1 : 0
  name       = "${local.gce_prefix}-autoscale"
  region     = var.region
  target     = google_compute_region_instance_group_manager.mig.self_link
  autoscaling_policy {
      max_replicas = var.max_replicas
      min_replicas = var.min_replicas
      cooldown_perios = var.cooldown_period
      cpu_utilization {
          target = var.autoscaling_cpu
      }
  }
}

provider "google-beta" {
    region = var.region
}

resource "google_compute_region_autoscaler" "metric-autoscaler" {
  count      = var.enable_metric_autoscaling ? 1 : 0
  name       = "${local.gce_prefix}-autoscale"
  provider   = google-beta
  region     = var.region
  target     = google_compute_region_instance_group_manager.mig.self_link
  autoscaling_policy {
      max_replicas = var.max_replicas
      min_replicas = var.min_replicas
      cooldown_perios = var.cooldown_period
      metric {
         name = var.metricname
         filter = var.filter
         single_instance_assignment = var.inst_assignment
      }
  }
}



// Forwarding rule for Internal Load Balancing
resource "google_compute_forwarding_rule" "fw_rule" {
  project               = var.project_name  
  name                  = "${local.gcn_prefix}-forwarding-rule"
  region                = var.region
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
      group = google_compute_region_instance_group_manager.mig.intance_group
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

 dynamic tcp_health_check {
     for_each = var.enable_health_check ? [1] : []
     content {
       port = var.hc_port
  }
}

 dynamic https_health_check {
     for_each = var.enable_https_health_check ? [1] : []
     content {
         port = var.hc_port
         request_path = var.hc_path
     }
 }
