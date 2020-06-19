resource "null_resource" "webserver1HTTPD" {
 depends_on = [oci_core_instance.webservervmserver1]
 provisioner "remote-exec" {
        connection {
                type     = "ssh"
                user     = "opc"
		host     = data.oci_core_vnic.webservervmserver1_VNIC1.public_ip_address
                private_key = file("${var.key_pair_path["private_key_path"]}")
                script_path = "/home/opc/myssh.sh"
                agent = false
                timeout = "10m"
        }
  inline = ["echo '== 1. Installing HTTPD package with yum'",
            "sudo -u root yum -y -q install httpd",

            "echo '== 2. Creating /var/www/html/index.html'",
            "sudo -u root touch /var/www/html/index.html", 
            "sudo /bin/su -c \"echo 'Welcome to webserver.com! This is WEBSERVER1...' > /var/www/html/index.html\"",

            "echo '== 3. Disabling firewall and starting HTTPD service'",
            "sudo -u root service firewalld stop",
            "sudo -u root service httpd start"]
  }
}