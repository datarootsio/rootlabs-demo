variable "domain_name" {
  type = string
}

variable "dns_zone" {
  type    = string
  default = "rootlabs-dataroots-io"
}

variable "environment" {
  type = string
}

variable "fg_color" {
  type = string
}

variable "bg_color" {
  type = string
}

variable "image_tag" {
  type = string
}