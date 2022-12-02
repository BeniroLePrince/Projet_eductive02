variable "region_GRA11" {
  default = "GRA11"
  type    = string
}

variable "SBG5" {
  default = "SBG5"
  type    = string
}

variable"i" {
   type = string
   default = 3
}

variable "instance_name_gra" {
  type     = string 
  default  = "backend_eductive02_gra"
}

variable "instance_name_sbg" {
  type    = string
  default = "backend_eductive02_sbg"
}

variable "image_name"{
  type    = string 
  default = "Debian 11"
}

variable "flavor_name" {
  type    = string 
  default = "s1-2"
}

