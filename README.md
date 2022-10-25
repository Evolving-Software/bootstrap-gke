# BootStrap GKE Cluster
This is a simple script to bootstrap a GKE cluster with a few basic components.

## Prerequisites
- [gcloud](https://cloud.google.com/sdk/gcloud/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [helm](https://helm.sh/docs/using_helm/#installing-helm)
- [knative client](https://github.com/knative/client/releases/tag/knative-v1.1.0)
- [terraform](https://www.terraform.io/downloads.html)
- [Flux CLI](https://fluxcd.io/flux/get-started/#install-the-flux-cli)

### Install gcloud
```bash
$ curl https://sdk.cloud.google.com | bash
$ exec -l $SHELL
$ gcloud init
```

### Install kubectl
```bash
$ gcloud components install kubectl
```

### Install helm
```bash
$ curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
```

### Install knative client

Linux AMD64
```bash
curl -L https://github.com/knative/client/releases/download/knative-v1.1.0/kn-linux-amd64
sudo mv kn-linux-amd64 /usr/local/bin/kn
sudo chmod +x /usr/local/bin/kn
echo 'export PATH=$PATH:/usr/local/bin/kn' >> ~/.bashrc
echo "Test kn installation"
kn version
```



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
4. Installs [Flux](https://fluxcd.io/) (Not yet implemented)

## What does it not do?
1. This project does not create a git repo for you. You will need to create a git repo and add the flux manifests to it.
2. This project does not create a docker registry for you. You will need to create a docker registry and add the container urls to the flux manifests.

## Resources
- [Knative](https://knative.dev/)
- [Flux](https://fluxcd.io/)
- [Kubernetes](https://kubernetes.io/)
- [GKE](https://cloud.google.com/kubernetes-engine/)
- [Flux CLI](https://knative.dev/docs/)

## Contributing
1. Fork this repo
2. Create a branch for your feature
3. Commit your changes
4. Push to your branch
5. Create a pull request

## [License](LICENSE.md)
APGL-3.0 © [RDS Ventures LLC](https://evolvingsoftware.io)

This license is based on the [GNU Affero General Public License](https://www.gnu.org/licenses/agpl-3.0.en.html) and is intended to protect the source code of the project and any derivative works. It is not intended to protect the data of the project. If you are using this project to store data, you should consider using a different license. Read the [License](LICENSE.md) for more information.

## Acknowledgements
Adopted from [Learn Terraform - Provision a GKE Cluster](https://github.com/hashicorp/learn-terraform-provision-gke-cluster) and [Knative Install ](https://knative.dev/docs/install/yaml-install/serving/install-serving-with-yaml/)