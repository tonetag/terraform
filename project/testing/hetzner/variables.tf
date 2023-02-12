variable "hcloud_token" {
  sensitive = true # Requires terraform >= 0.14
}

variable "ssh_pubkey_path" {
    type = string
    default = "~/.ssh/id_ed25519.pub"
}

variable "ssh_privkey_path" {
    type = string
    default = "~/.ssh/id_ed25519"
}