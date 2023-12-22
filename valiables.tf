# from terraform.tfvars
variable "project_key_path" {
  description = "Key path to GCP project"
}
variable "gcp_project_id" {
  description = "GCP project id"
}
variable "gcp_region" {
  description = "GCP region"
}

# others
variable "cluster_name" {
  description = "name of gke cluster"
  default     = "dev-cluster"
}
variable "env_name" {
  description = "name of environment"
  default     = "dev"
}
variable "network" {
  description = "name of VPC"
  default     = "dev-gke-network"
}
variable "subnetwork" {
  description = "name of subnetwork"
  default     = "dev-gke-subnet"
}
variable "ip_range_pods_name" {
  description = "name of secondary ip range used in pods"
  default     = "ip-range-pods"
}
variable "ip_range_services_name" {
  description = "name of secondary ip range used in services"
  default     = "ip-range-services"
}