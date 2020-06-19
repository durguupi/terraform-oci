# To create VCN in OCI

resource "oci_core_virtual_network" "webservervcn" {
  cidr_block = var.vcn_cidr
  compartment_id = oci_identity_compartment.webservercompartment.id
  display_name = "WebServerVCN"
}

# Gets a list of Availability Domains
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

# To create Regional Subnet in OCI VCN

resource "oci_core_subnet" "webserver_publicsubnet" {
  cidr_block = "10.0.1.0/24"
  display_name = "WebServer_publicsubnet"
  compartment_id = oci_identity_compartment.webservercompartment.id
  vcn_id = oci_core_virtual_network.webservervcn.id
  dhcp_options_id = oci_core_dhcp_options.webserverdhcp.id
  route_table_id = oci_core_route_table.webserverroutetableIGW.id
  security_list_ids = [oci_core_security_list.webserversecuritylist_public.id]
}

# To create Internet Gateway

resource "oci_core_internet_gateway" "webserver_igw" {
    compartment_id = oci_identity_compartment.webservercompartment.id
    display_name = "WebServerInternetGateway"
    vcn_id = oci_core_virtual_network.webservervcn.id
}
# DHCP options

resource "oci_core_dhcp_options" "webserverdhcp" {
  compartment_id = oci_identity_compartment.webservercompartment.id
  vcn_id = oci_core_virtual_network.webservervcn.id
  display_name = "WebServercompartmentDHCPoptions"

  // required
  options {
    type = "DomainNameServer"
    server_type = "VcnLocalPlusInternet"
  }
   // optional
  options {
    type = "SearchDomain"
    search_domain_names = [ "webservertest.com" ]
  }
}

# Creating Public routetable

resource "oci_core_route_table" "webserverroutetableIGW" {
    compartment_id = oci_identity_compartment.webservercompartment.id
    vcn_id = oci_core_virtual_network.webservervcn.id
    display_name = "WebServerroutetableviaIGW"
    route_rules {
        destination = "0.0.0.0/0"
        destination_type  = "CIDR_BLOCK"
        network_entity_id = oci_core_internet_gateway.webserver_igw.id
    }
}

# Security list for public subnet
resource "oci_core_security_list" "webserversecuritylist_public" {
    compartment_id = oci_identity_compartment.webservercompartment.id
    display_name = "WebServerSecurityList_public"
    vcn_id = oci_core_virtual_network.webservervcn.id
    
    egress_security_rules {
        protocol = "6"
        destination = "0.0.0.0/0"
    }
    
    dynamic "ingress_security_rules" {
    for_each = var.service_ports
    content {
        protocol = "6"
        source = "0.0.0.0/0"
        tcp_options {
            max = ingress_security_rules.value
            min = ingress_security_rules.value
            }
        }
    }

    ingress_security_rules {
        protocol = "6"
        source = var.vcn_cidr
    }
}