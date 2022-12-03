# PoC GKE Deployment

In this chapter I'm going to demonstrate how to use resources of your PC in order to deploy your own infrastructure.
The GKE cluster will be deployed in the GCP.

## Run deploymnet process by Github Action

In order to run our pipelines we will use self-hosted Github Action runners.

### Prepare Github Action Controller

* As a platform for running Github Action we will use Docker Desktop
* In order to avoid specifing kubernetes context all the time in the commands, let's set default context

```bash
kubectl config use-context docker-desktop
```

* Cert-manager is the mandatory component for installing the actions-runner-controller (ARC)

```bash
helm repo add jetstack "https://charts.jetstack.io"
helm repo update
helm upgrade --install cert-manager jetstack/cert-manager \
--namespace cert-manager \
--create-namespace \
--version v1.8.0 \
--set installCRDs=true
```

* Install actions-runner-controller (ARC)

```bash
helm repo add actions-runner-controller "https://actions-runner-controller.github.io/actions-runner-controller"
helm repo update
helm upgrade --install actions-runner-controller actions-runner-controller/actions-runner-controller \
--namespace actions-runner-system \
--create-namespace \
--version 0.21.1 \
--wait \
--values .github/arc/values.yml --set "authSecret.github_token=YOUR_PAT"
```

* Add Runner

```bash
kubectl -n actions-runner-system apply -f .github/arc/RunnerDeployment.yml
kubectl -n actions-runner-system patch RunnerDeployment poc-gke-envs --type='json' \
-p='[{"op": "add", "path": "/spec/template/spec/volumes/0", "value":{"name":"gcp-credentials","hostPath":{"path":"/Users/'$LOGNAME'/.config/"}}}]'
```

* Remove Runner for our env's repository

```bash
kubectl -n actions-runner-system delete RunnerDeployment poc-gke-envs
```
