provider "aws" {
  default_tags {
    tags = var.tags
  }
}

provider "helm" {
  kubernetes {
    host                   = module.managed_eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.managed_eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", module.managed_eks.cluster_name]
    }
  }
}

provider "helm" {
  alias = "argocdcluster"
  kubernetes {
    host                   = data.aws_eks_cluster.argocd.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.argocd.certificate_authority[0].data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.argocd.name]
    }
  }
}
