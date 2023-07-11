variable "project_name" {
  default = ""
}

variable "region" {
  type = string
  default = "europe-west2"
}

variable "zone" {
  default = ""
}

variable "subnetwork" {
  default = ""
}

variable "tags" {
  type = list(string)
  default = [""]
}

variable "linux" {
  default = false
}

variable "windows" {
  default = false
}

variable "application" {
  default = ""
}

variable "ssh-keys" {
  default = ""
}

## Instance template and group

variable "name" {
  default = ""
}

variable "mode" {
  default = "READ_WRITE"
}
variable "type" {
  default = "PERSISTENT"
}

variable "disk_type" {
  default = "pd_standard"
}

variable "attached_disk_size" {
  default = 100
}

variable "snapshot_attached" {
  default = ""
}

variable "disk_size" {
  default = 100
}

variable "image" {
  default = ""
}
variable "snapshot_boot" {
  default = ""
}
variable "ports" {
  type = list(number)
  default = [443]
}

variable "target_size" {
  default = ""
}

variable "startup_script" {
  default = ""
}

variable "init_script" {
  default = "init-script.bash"
}

variable "network_ip" {
  default = ""
}

variable "machine_type" {
  default = ""
}
variable "compute_image" {
  default = ""
}

variable "update_strategy" {
  default = "RESTART"
}

variable "service_port" {
  default = "443"
}

variable "service_port_name" {
  default ="port"
}

variable "target_tags" {
  type  =  list(string)  
  default = [""]
}

variable "target_pools" {
  type = list(string)
  default = []
}

variable "cmek_key" {
  type   = list(string)  
  default = []
}

variable "depends_id" {
  default = ""
}

variable "local_cmd_destroy" {
  default = ":"
}

variable "service_account_email" {
  default = "default"
}

variable "service_account_scopes" {
  default = ""
}

variable "address" {
  default = null
}

## Autoscaling
variable "autoscaling" {
  default = false
}

variable "max_replicas" {
  default = 3
}

variable "min_replicas" {
  default = 1
}

variable "cooldown_period" {
  default = 60
}

variable "autoscaling_cpu" {
  type  = list(string)  
  default = []
}

variable "autoscaling_metric" {
  default = ""
}

variable "autoscaling_lb" {
  default = []
}

## Health Checks
variable "http_health_check" {
  default = true
}

variable "hc_initial_delay" {
  default = 300
}

variable "hc_interval" {
  default = 30
}

variable "hc_timeout" {
  default = 10
}

variable "hc_healthy_threshold" {
  default = 1
}

variable "hc_unhealthy_threshold" {
  default = 10  
}

variable "hc_port" {
  default = 443
}

# variable "hc_path" {
#   default = "/"
# }

variable "scheme" {
  default = "INTERNAL"
}




