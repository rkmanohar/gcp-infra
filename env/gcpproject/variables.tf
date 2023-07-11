variable "project_name" {
  default = " My First Project"
}

variable "region" {
  type    = string
  default = "us-west2"
}

variable "zone" {
  default = ""
}

variable "subnetwork" {
  default = ""
}

variable "project_id" {
  default = "parabolic-craft-290613"
}

variable "image" {
  default = "rhel-7-v20200403"
}