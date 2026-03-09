locals {
  manifests_dir = "${path.module}/manifests"
  
  # Compute a SHA1 hash of all Kustomize manifests.
  # This is used to trigger replace.
  kustomize_manifests_hash = sha1(join("", [
    for f in fileset(local.manifests_dir, "**") : filesha1("${local.manifests_dir}/${f}")
  ]))

  # Path to the overlay manifests for the current environment
  overlay_path  = "${local.manifests_dir}/overlays/${var.environment}"
}


resource "terraform_data" "olm_crds" {
  provisioner "local-exec" {
    command = "kubectl apply --server-side -f ${path.module}/manifests/crds"
  }
}

# Apply Kustomize overlays for the current environment
resource "terraform_data" "olm" {
  depends_on = [ terraform_data.olm_crds ]

  input = {
    env          = var.environment
    overlay_path = local.overlay_path
  }

  # Re-run if environment or overlay files change
  triggers_replace = [
    var.environment,
    local.kustomize_manifests_hash
  ]

  provisioner "local-exec" {
    command = "kubectl apply -k ${self.input.overlay_path}"
  }
}