module "portworx-enterprise" {
  source  = "https://github.com/mattokc35/terraform-portworx-ibmcloud.git"
  # insert the 3 required variables here
  region                    = "${var.region}"
  cluster_name              = "${var.cluster_name}"
  resource_group            = "${var.resource_group}"
  ibmcloud_api_key          = var.ibmcloud_api_key 
  cluster_config_path       = data.ibm_container_cluster_config.cluster.config_file_path
  portworx_service_name     = var.portworx_service_name
  use_cloud_drives = var.use_cloud_drives
  cloud_drive_options = {
    max_storage_node_per_zone = var.max_storage_node_per_zone
    num_cloud_drives = var.num_cloud_drives
    cloud_drives_sizes = var.cloud_drives_sizes
    storage_classes = var.storage_classes
  }
  
}


terraform {
  required_version = ">=0.13"
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = ">= 1.45.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.4.3"
    }

    null = {
      source  = "hashicorp/null"
      version = ">= 3.1.1"
    }
  }
}

##############################################################################
# Cluster Data
##############################################################################

data "ibm_container_vpc_cluster" "cluster" {
  name = "${var.cluster_name}"
}

##############################################################################

##############################################################################
# Cluster Config Data
##############################################################################

data "ibm_container_cluster_config" "cluster" {
  cluster_name_id = "${var.cluster_name}"
  admin           = false
}

##############################################################################

##############################################################################
# Kubernetes Provider
##############################################################################

provider "kubernetes" {
  host                   = data.ibm_container_cluster_config.cluster.host
  client_certificate     = data.ibm_container_cluster_config.cluster.admin_certificate
  client_key             = data.ibm_container_cluster_config.cluster.admin_key
  cluster_ca_certificate = data.ibm_container_cluster_config.cluster.ca_certificate
}

##############################################################################



provider "ibm" {
  region = "us-south"
  ibmcloud_api_key = var.ibmcloud_api_key
}


variable "ibmcloud_api_key" {
    type = string  
    sensitive = true
}

variable "resource_group" {
    type = string
    default = "default"
}

variable portworx_service_name {
   type = string
}

variable cluster_name {
   type = string
}

variable region {
   type = string
   default = "us-south"
}

##############################################################################
# cloud_drive_options
# max_storage_node_per_zone : "Maximum number of strorage nodes per zone, you can set this to the maximum worker nodes in your cluster"
# num_cloud_drives : "Number of cloud drives per zone, Max: 3"
# cloud_drives_sizes : "Size of Cloud Drive in GB, ex: [50, 60, 70], the number of elements should be same as the value of `num_cloud_drives`"
# storage_classes : "Storage Classes for each cloud drive, ex: [ "ibmc-vpc-block-10iops-tier", "ibmc-vpc-block-5iops-tier", "ibmc-vpc-block-general-purpose"], the number of elements should be same as the value of `num_cloud_drives`"
  
##############################################################################

variable max_storage_node_per_zone{
  type = number 
}

variable num_cloud_drives{
  type = number 
  default = 3
}

variable cloud_drives_sizes {
  type = list(number)
  default = [200,200,200]
}

variable storage_classes {
  type = list(string)
  default = ["ibmc-vpc-block-5iops-tier", "ibmc-vpc-block-5iops-tier", "ibmc-vpc-block-5iops-tier"]
}


variable use_cloud_drives {
  type = bool
  default = true
}
