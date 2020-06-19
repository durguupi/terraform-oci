resource "oci_core_instance" "webservervmserver1" {
  availability_domain = lookup(data.oci_identity_availability_domains.ads.availability_domains[0],"name")
  compartment_id = oci_identity_compartment.webservercompartment.id
  display_name = "WebServerVMServer1"
  shape = var.instance_shape
  subnet_id = oci_core_subnet.webserver_publicsubnet.id
   source_details {
    source_type = "image"
    source_id   = var.instance_image_ocid[var.region]
  }

  metadata = {
      ssh_authorized_keys = file("${var.key_pair_path["public_key_path"]}")
  }
  create_vnic_details {
     subnet_id = oci_core_subnet.webserver_publicsubnet.id
     assign_public_ip = true 
  }
}
# VNCI Attachement details more control over VNIC so we will use the below blocks 
# Gets a list of vNIC attachments on the instance
data "oci_core_vnic_attachments" "webservervmserver1_VNIC1_attach" {
  availability_domain = lookup(data.oci_identity_availability_domains.ads.availability_domains[0],"name")
  compartment_id = oci_identity_compartment.webservercompartment.id
  instance_id = oci_core_instance.webservervmserver1.id
}
# Gets the OCID of the first (default) vNIC
data "oci_core_vnic" "webservervmserver1_VNIC1" {
  vnic_id = data.oci_core_vnic_attachments.webservervmserver1_VNIC1_attach.vnic_attachments.0.vnic_id
}

output "sandboxvmserver1PublicIP" {
   value = ["${data.oci_core_vnic.webservervmserver1_VNIC1.public_ip_address}"]
}

# # This one is without VNIC details we can get the public IP address
# output "sandboxPrimaryPublicIP"{
#     value = "${oci_core_instance.sandboxvmserver1.public_ip}"
# }
