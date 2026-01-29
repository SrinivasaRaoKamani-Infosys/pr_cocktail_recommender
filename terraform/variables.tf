variable "location" {
type = string
}

variable "resource_group_name" {
type = string
}

variable "acr_login_server" {
type = string
}

variable "frontend_image" {
default = "frontend-app:latest"
}

variable "backend_image" {
default = "backend-app:latest"
}
