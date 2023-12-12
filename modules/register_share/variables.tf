variable "computerName" {
  description = "(Required) The computer name that will be created for the "
  type        = string
}

variable "computerDscr" {
  description = "(Required) The description of computer object that will be created in the AD."
  type        = string
}

variable "kv_id" {
  description = "(Optionnal) key vault id"
  type        = string
  default     = ""
}
