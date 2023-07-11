module "gcetest" {
  source       = "../../modules/mig"
  linux        = "true"
  application  = "cloud-connect"
  project_name = var.project_id
  subnetwork   = var.subnetwork
  environemnt  = local.environment
  metadata     = var.cloud_connect_metadata
  cmek_key     = var.cmek_key
  tags         = var.tags
  image        = var.cloud_connect_image
  ssh_keys     = data.template_file.ssh-keys-cloud-connect.rendered
  subnetwork   = var.subnetwork
  enable_dualnic = true
  subnetwork1    = var.subnetwork1
  ip_address     = module.cloud_connect_ip.ip_address
  vm_ip_address  = module.cloud_connect_vm_ip.ip_address
  disk_size      = var.cloud_connect_disk_size
  attached_disk_size    = var.cloud_connect_attached_disk_size
  tags                  = var.cloud_connect_tags
  ports                 = var.cloud_connect_ports

}

module "cloud_connect_bucket" {
  source    = ""../../modules/gcs"
  name      = "${local.project_name}-cloud-connect"
  environment =  local.environment
  project_id  =  local.project_name
  region      =  "var.region"
  iam_members = [
    {
     role  = "roles/storage.objectAdmin"
     member = "serviceAccount:cloud-connect@${local.project_name}-${local.environment}.iam.gserviceaccount.com"
    }
  ]
 }
 
 module "pubsub_gcsnotification"  {
   source    = ""../../modules/pubsub"
   project = "${local.project_name}
   topic   = "topic-name"
   subscription = "subscription-name"
   bucket  = "bucket-name"
   cmek_key  = var.cmek_key
   payloadformat = "JSON_API_VI"
   eventtype = ["OBJECT_FINALIZE"]
   prefix = "input/"
}

module "jenkins_platform_node" {
   source    = ""../../modules/single_template"
   linux     = true
  application = "jenkins"
  env         = local.environment
  project_name = local.project_name
  name    = var.jenkins_node_image
  disk_size = var.jenkins_node_disk_size
  tags      = var.jenkins_tags
}
  
 
