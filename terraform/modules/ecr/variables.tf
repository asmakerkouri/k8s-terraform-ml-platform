variable "name" {
  type = string
}

variable "keep_images" {
  type    = number
  default = 20
}

variable "force_delete" {
  type    = bool
  default = true
}

variable "tags" {
  type    = map(string)
  default = {}
}
