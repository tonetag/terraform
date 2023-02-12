resource "hcloud_primary_ip" "main" {
  name          = "primary_ip_test"
  datacenter    = "fsn1-dc14"
  type          = "ipv4"
  assignee_type = "server"
  auto_delete   = true
  labels = {
    "env" : "dev"
  }
}

resource "hcloud_ssh_key" "ssh_key_test" {
  name       = "SSH Key"
  public_key = file("${var.ssh_pubkey_path}")
}

resource "hcloud_server" "server_main" {
  name        = "test-server"
  image       = "ubuntu-20.04"
  server_type = "cx31" # For IntelliJ IDEA Remote Development
  datacenter  = "fsn1-dc14"
  labels = {
    "env" : "dev"
  }
  public_net {
    ipv4_enabled = true
    ipv4 = hcloud_primary_ip.main.id
    ipv6_enabled = false
  }

  ssh_keys = [
    hcloud_ssh_key.ssh_key_test.id
  ]

  provisioner "remote-exec" {
    inline = ["sudo apt update", "sudo apt install python3 -y"]

    connection {
      host        = self.ipv4_address
      type        = "ssh"
      user        = "root"
      private_key = file(var.ssh_privkey_path)
    }
  }


  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u root -i '${self.ipv4_address},' --private-key ${var.ssh_privkey_path} -e 'pub_key=${var.ssh_pubkey_path}' ansible-setup.yml"
  }

}

output "server_ip" {
  value = hcloud_server.server_main.ipv4_address
}