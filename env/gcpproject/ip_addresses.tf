module "cloud_connect_ip" {
  source = "../..modules/ip-address"
  subnetwork = var.subnetwork
  application = "cloud-connect"
  region    = var.region
}
  
module "cloud_connect_vm_ip" {
  source = "../..modules/ip-address"
  subnetwork = var.subnetwork
  application = "cloud-connect-vm"
  ip_address  = "10.91.4.221"
  region    = var.region
}
  
  
