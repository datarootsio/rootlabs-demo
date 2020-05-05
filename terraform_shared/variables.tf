variable "dns_names" {
  type = list(string)
  default = ["iac.rootlabs.dataroots.io","staging-iac.rootlabs.dataroots.io"]
}

variable "dns_zone" {
  type = string
  default = "rootlabs-dataroots-io"
}