variable "name" {
  type        = string
  description = "Bucket name"
}

variable "tags" {
  type    = map(string)
  default = {}
}
