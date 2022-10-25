# BootStrap GKE Cluster
This is a simple script to bootstrap a GKE cluster with a few basic components.

## Prerequisites
- [gcloud](https://cloud.google.com/sdk/gcloud/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [helm](https://helm.sh/docs/using_helm/#installing-helm)

## Usage
1. Clone this repo
2. Make bootstrap.sh executable
    ```bash
    chmod +x bootstrap.sh
    ```
3. Run bootstrap.sh
    ```bash
    ./bootstrap.sh
    ```
4. Follow the prompts

## What does it do?
1. Creates a GKE cluster
2. Installs [Knative Serving](https://knative.dev/docs/serving/)
3. Installs [Knative Eventing](https://knative.dev/docs/eventing/)
4. Installs [Flux](https://fluxcd.io/)

## What does it not do?
1. This project does not create a git repo for you. You will need to create a git repo and add the flux manifests to it.
2. This project does not create a docker registry for you. You will need to create a docker registry and add the container urls to the flux manifests.

## Resources
- [Knative](https://knative.dev/)
- [Flux](https://fluxcd.io/)
- [Kubernetes](https://kubernetes.io/)
- [GKE](https://cloud.google.com/kubernetes-engine/)

## Contributing
1. Fork this repo
2. Create a branch for your feature
3. Commit your changes
4. Push to your branch
5. Create a pull request

## [License](LICENSE)
APGL-3.0 © [RDS Ventures LLC](https://evolvingsoftware.io)
