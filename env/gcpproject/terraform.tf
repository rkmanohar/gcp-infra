# provider "template" {
#   version = "~> 1.66.0"
# }

# # provider "google" {
# #   version = "~> 2.20"
# # }


# # provider "google-beta" {
# #   version = "~> 2.20"
# # }

terraform {
  backend "gcs" {
    bucket = "statefile-tf"
  }

}
