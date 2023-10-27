variable "managed_connection" {
  description = "Don't ask"
  type        = bool
  default     = false
}

variable "shutdown_script" {
  description = "Name of the shutdown script"
  type        = string
  default     = "abandon.sh"
}
