variable "name" {
 description  = "The name of the bucket"
 type  = string
}

variable "project_id" {
 description  = "The ID of the project to create the bucket in"
 type  = string
}

variable "location" {
 description  = "The location of the bucket"
 type  = string
 default = "europe-west2"
}

Variable "environment" {
}

variable "storage_class" {
 description  = "The Storage of the new bucket"
 type  = string
 default  = "REGIONAL"
}

variable "labels" {
 description  = "A set of key/value pairs to assign to the bucket"
 type  = map(string)
 default  = null
}

variable "bucket_policy_only" {
 description  = "Enables Bucket policy only access to a bucket"
 type  = bool
 deafult = true
}

variable "versioning" {
 description  = "while set to true, versioning is fully enabled for this bucket"
 type  = bool
 default = true
}

variable "iam_members" {
 description  = "The list of IAM members to grant permsissions on the bucket"
 type  = list(object({
   role  = string
   member = string
   }))
   default = []
 }
 
 variable "cmek" {
 description  = "A cloud KMS key that will be used to encrypt objects inserted into this bucket"
 default = ''
}

variable "force_destroy" {
 description  = "A boolean value to determine if the bucket should be force destroyed. (destroyed with data)"
 type  = bool
 default = false
}

variable "lifecycle_rules" {
 description  = "The bucket's Lifecycle Rules configuration"
 type  = list(object({
 action = any
 
 condition = any
 }))
 default = []
 }
 default = false
}
