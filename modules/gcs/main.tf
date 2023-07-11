resource "google_storage_bucket" "bucket" {
  name    = var.name
  project = var.project_id
  location = var.location
  storage_class = var.storage_class
  bucket_policy_only = var.bucket_policy_only
  labels    = var.labels
  force_destroy   = var.force_destroy
  
  versioning {
  enabled = var.versioning 
  }
  
  encryption {
    default_kms_key_name  = "projects/project-kmskey/locations/europe-west2/keyRings/cloudStorage/cryptoKeys/HSMcloudStorage"
  }
  
  dynamic "lifecycle_rule" {
    for_each = var.lifecycle_rules
    content {
    action {
     type  = lifecycle_rule.value.action.type
     storage_class  = lookup(lifecycle_rule.value.action, "storage_class", null}
     }
     condition {
     age                     = lookup(lifecycle_rule.value.condition, "age", null)
     created_before          = lookup(lifecycle_rule.value.condition, "created_before", null)
     with_state              = lookup(lifecycle_rule.value.condition, "with_state", lookup(lifecycle_rule.value.condition, "is_live", false) ? "LIVE" : null)
     matches_storage_class   = lookup(lifecycle_rule.value.condition, "matches_storage_class", null)
     num_newer_versions      = lookup(lifecycle_rule.value.condition, "num_newer_versions", null)
  }
 }
}
}

resource "google_storage_bucket_iam_member" "members" {
for_each = {
 for m in var.iam_members : "${m.role} ${m.member}" => m
}
bucket  = google_storage_bucket.bucket.name
role    = each.value.role
member  = each.value.member
}
