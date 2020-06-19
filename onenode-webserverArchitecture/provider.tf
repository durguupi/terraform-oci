# To use version use this one version = ">= 3.65.0" 
provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}
# To create Compartment 
resource "oci_identity_compartment" "webservercompartment" {
  name = "webserverompartment"
  description = "Sandbox Compartment"
  compartment_id = var.compartment_ocid
  enable_delete = true
}
