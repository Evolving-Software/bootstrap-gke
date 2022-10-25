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

# # Deploy the Kubernetes Dashboard
echo "Deploying Kubernetes Dashboard 🚀"
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta8/aio/deploy/recommended.yaml

# Install Knative CRDs, Knative Serving, and Knative Eventing components
echo "Installing Knative CRDs, Knative Serving, and Knative Eventing components 🚀"

kubectl apply --selector knative.dev/crd-install=true \
  --filename "https://github.com/knative/serving/releases/\
download/v1.1.0/serving.yaml" \
  --filename "https://github.com/knative/eventing/releases/\
download/v1.1.0/eventing.yaml"

# Querying for the CRDs and Serving CRDs to be ready
echo "Querying for the CRDs and Serving CRDs to be ready 🚀"
kubectl api-resources --api-group=serving.knative.dev

# Querying for the Eventing CRDs to be ready
echo "Querying for the Eventing CRDs to be ready 🚀"
kubectl api-resources --api-group=eventing.knative.dev

# Querying for the messaging CRDs to be ready
echo "Querying for the messaging CRDs to be ready 🚀"
kubectl api-resources --api-group=messaging.knative.dev

# Querying for the sources CRDs to be ready
echo "Querying for the sources CRDs to be ready 🚀"
kubectl api-resources --api-group=sources.eventing.knative.dev
kubectl api-resources --api-group=sources.knative.dev


# Deploy the Knative Serving infrastructure components
echo "Deploying the Knative Serving infrastructure components 🚀"
kubectl apply \
  --filename \
  https://github.com/knative/serving/releases/download/knative-v1.1.0/serving-core.yaml
  # Wait for the Knative Serving components to be ready
    echo "Waiting for the Knative Serving components to be ready 🚀"

kubectl rollout status deploy controller -n knative-serving
kubectl rollout status deploy activator -n knative-serving
kubectl rollout status deploy autoscaler -n knative-serving
kubectl rollout status deploy webhook -n knative-serving

  # Monitor the Knative Serving components until all of the components show a STATUS of Running or Completed:
echo "Monitoring the Knative Serving components until all of the components show a STATUS of Running or Completed 🚀"
kubectl get pods --namespace knative-serving

# Install Kourier Ingress Gateway
echo "Installing Kourier Ingress Gateway 🚀"
kubectl apply \
  --filename \
    https://github.com/knative/net-kourier/releases/download/knative-v1.1.0/kourier.yaml

    # Wait for the Kourier Ingress Gateway to be ready
echo "Waiting for the Kourier Ingress Gateway to be ready 🚀"
kubectl rollout status deploy 3scale-kourier-control -n knative-serving
kubectl rollout status deploy 3scale-kourier-gateway -n kourier-system

# Show Kourier Pods
echo "Showing Kourier Pods 🚀"
kubectl get pods --all-namespaces -l 'app in(3scale-kourier-gateway,3scale-kourier-control)'

# Configure Knative serving to use Kourier as the ingress
echo "Configuring Knative serving to use Kourier as the ingress 🚀"
kubectl patch configmap/config-network \
  -n knative-serving \
  --type merge \
  -p '{"data":{"ingress.class":"kourier.ingress.networking.knative.dev"}}'

# Install and Configure Ingress Controller
echo "Installing and Configuring Ingress Controller 🚀"
kubectl apply \
  --filename https://projectcontour.io/quickstart/contour.yaml

# Wait for the Ingress to be deployed and running:
echo "Waiting for the Ingress to be deployed and running 🚀"
kubectl rollout status ds envoy -n projectcontour
kubectl rollout status deploy contour -n projectcontour

# Show Contour Pods
echo "Showing Contour Pods 🚀"
kubectl get pods -n projectcontour

# Create an ingress to Kourier Ingress Gateway
echo "Creating an ingress to Kourier Ingress Gateway 🚀"
cat <<EOF | kubectl apply -n kourier-system -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: kourier-ingress
  namespace: kourier-system
spec:
  rules:
  - http:
     paths:
       - path: /
         pathType: Prefix
         backend:
           service:
             name: kourier
             port:
               number: 80
EOF

# Configure Knative to use the kourier-ingress Gateway:
echo "Configuring Knative to use the kourier-ingress Gateway 🚀"
kubectl apply -f https://github.com/knative/serving/releases/download/knative-v1.1.0/serving-default-domain.yaml

# Install Autoscaling 
echo "Installing Autoscaling 🚀"
kubectl apply -f https://github.com/knative/serving/releases/download/knative-v1.1.0/serving-hpa.yaml


# Install Knative Eventing
echo "Installing Knative Eventing 🚀"
kubectl apply \
  --filename \
  https://github.com/knative/eventing/releases/download/knative-v1.1.0/eventing-core.yaml \
  --filename \
  https://github.com/knative/eventing/releases/download/knative-v1.1.0/in-memory-channel.yaml \
  --filename \
  https://github.com/knative/eventing/releases/download/knative-v1.1.0/mt-channel-broker.yaml


# Wait for the Knative Eventing components to be ready
echo "Waiting for the Knative Eventing components to be ready 🚀"
kubectl rollout status deploy eventing-controller -n knative-eventing
kubectl rollout status deploy eventing-webhook  -n knative-eventing
kubectl rollout status deploy imc-controller  -n knative-eventing
kubectl rollout status deploy imc-dispatcher -n knative-eventing
kubectl rollout status deploy mt-broker-controller -n knative-eventing
kubectl rollout status deploy mt-broker-filter -n knative-eventing
kubectl rollout status deploy mt-broker-filter -n knative-eventing


# Get Knative eventing pods
echo "Getting Knative eventing pods 🚀"
kubectl get pods --namespace knative-eventing

# Create namespace for Knative 
echo "Creating namespace for Knative 🚀"
kubectl create namespace knative

kubectl config set-context --current --namespace=knative

kubens knative

# Create a knative test service
echo "Creating a knative test service 🚀"
kn service create greeter \
  --image quay.io/rhdevelopers/knative-tutorial-greeter:quarkus

# Show Knative service
echo "Showing Knative service 🚀"
kn service list

This is optional. 

# If you want to deploy this behind the load balance you need to change the yaml
# # Create a proxy to the Kubernetes Dashboard
# echo "Creating proxy to Kubernetes Dashboard 🚀"
# kubectl proxy & echo $! > kubectl-proxy.pid


# # Authenticate to the Kubernetes Dashboard
# echo "Authenticating to Kubernetes Dashboard 🚀"
# kubectl apply -f https://raw.githubusercontent.com/hashicorp/learn-terraform-provision-gke-cluster/main/kubernetes-dashboard-admin.rbac.yaml

# # Get the token to authenticate to the Kubernetes Dashboard
# echo "Getting token to authenticate to Kubernetes Dashboard 🚀"
# kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep service-controller-token | awk '{print $1}')
