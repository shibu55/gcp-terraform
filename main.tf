terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.10.0"
    }
  }
}

provider "google" {
  credentials = file(var.project_key_path)

  project = var.gcp_project_id
  region  = var.gcp_region
  zone    = "${var.gcp_region}-a"
}

# network
module "vpc" {
  source       = "terraform-google-modules/network/google"
  version      = "8.1.0"
  project_id   = var.gcp_project_id
  network_name = "${var.network}-${var.env_name}"
  subnets = [
    {
      subnet_name   = "${var.subnetwork}-${var.env_name}"
      subnet_ip     = "10.10.0.0/16"
      subnet_region = var.gcp_region
    },
  ]
  secondary_ranges = {
    "${var.subnetwork}-${var.env_name}" = [
      {
        range_name    = var.ip_range_pods_name
        ip_cidr_range = "10.20.0.0/16"
      },
      {
        range_name    = var.ip_range_services_name
        ip_cidr_range = "10.30.0.0/16"
      },
    ]
  }
}

# gke
module "gke" {
  source            = "terraform-google-modules/kubernetes-engine/google//modules/private-cluster"
  project_id        = var.gcp_project_id
  name              = "${var.cluster_name}-${var.env_name}"
  regional          = true
  region            = var.gcp_region
  network           = module.vpc.network_name
  subnetwork        = module.vpc.subnets_names[0]
  ip_range_pods     = var.ip_range_pods_name
  ip_range_services = var.ip_range_services_name
  node_pools = [
    {
      name           = "node-pool"
      machine_type   = "n2-standard-2"
      node_locations = "${var.gcp_region}-a" # 複数のゾーンを指定できる
      min_count      = 1
      max_count      = 2
      disk_size_gb   = 30
    },
  ]
}

# gke auth
module "gke_auth" {
  source       = "terraform-google-modules/kubernetes-engine/google//modules/auth"
  depends_on   = [module.gke]
  project_id   = var.gcp_project_id
  location     = module.gke.location
  cluster_name = module.gke.name
}

# kubeconfig
resource "local_file" "kubeconfig" {
  content  = module.gke_auth.kubeconfig_raw
  filename = "kubeconfig-${var.env_name}"
}
