#!/bin/sh
# Copyright (C) 2022 RDS Ventures LLC
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
# 
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.


# This script is intended to deploy a fresh GKE cluster with the
# necessary components to run the Evolving Solutions platform. It is intended to be
# run from a fresh GCP project with no existing resources.

# This script assumes that the following environment variables are set:
# - project_id: The GCP project to deploy to
# - region: The GCP zone to deploy to



echo "Bootstrapping GKE cluster using Terraform"

# Initialize Terraform
echo "Initializing Terraform 🚀"
terraform init

# Deploy the GKE cluster
echo "Deploying GKE cluster 🚀"
terraform apply -auto-approve

# Get the GKE credentials
echo "Getting GKE credentials 🚀"
gcloud container clusters get-credentials $(terraform output -raw kubernetes_cluster_name) --region $(terraform output -raw region)

# Deploy the Kubernetes Dashboard
echo "Deploying Kubernetes Dashboard 🚀"
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta8/aio/deploy/recommended.yaml

# Create a proxy to the Kubernetes Dashboard
echo "Creating proxy to Kubernetes Dashboard 🚀"
kubectl proxy

# Authenticate to the Kubernetes Dashboard
echo "Authenticating to Kubernetes Dashboard 🚀"
kubectl apply -f https://raw.githubusercontent.com/hashicorp/learn-terraform-provision-gke-cluster/main/kubernetes-dashboard-admin.rbac.yaml

# Get the token to authenticate to the Kubernetes Dashboard
echo "Getting token to authenticate to Kubernetes Dashboard 🚀"
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep service-controller-token | awk '{print $1}')


