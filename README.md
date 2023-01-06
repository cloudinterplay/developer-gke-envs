# PoC GKE Deployment

In this chapter I'm going to demonstrate how to use resources of your PC in order to deploy your own infrastructure.
The GKE cluster will be deployed in the GCP.

## Prepare Dev Container

In order to keep Operation System away from any application and packages installation we are going to use development container (so we don't need to install anything on your computer except docker-desktop).

After activating the dev container we need to authenticate our-self against out GCP account

```bash
gcloud auth application-default login
```

Now we have an auth token for our GCP account stored in the hidden ".config/gcloud/" folder, which will be used by terraform inside the github runner.

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
kubectl -n actions-runner-system patch RunnerDeployment developer-gke-envs --type='json' \
-p='[{"op": "add", "path": "/spec/template/spec/volumes/0", "value":{"name":"gcp-credentials","hostPath":{"path":"/Users/'$LOGNAME'/.config/"}}}]'
```

* Check if our runnera are working

```bash
root@cte-poc-gke-envs:/automation/cloudinterplay/poc-gke-envs# kubectl -n actions-runner-system get pods
NAME                                         READY   STATUS    RESTARTS   AGE
actions-runner-controller-77f44ff945-pcfcf   2/2     Running   0          1h
poc-gke-envs-dzwvb-99vcq                     2/2     Running   0          1h
poc-gke-envs-dzwvb-mwth5                     2/2     Running   0          1h
```

* Remove Runner for our env's repository

```bash
kubectl -n actions-runner-system delete RunnerDeployment poc-gke-envs
```

## Check the GKE cluster and local development

In order to be able to run the deployment scripts locally, we needs to be authenticated as an user (not as an application)

```bash
gcloud auth login
```

Next, we need to set the project ID and request credentials for the cluster we've deployed

```bash
gcloud config set project ${PROJECT_ID}
gcloud container clusters get-credentials ${CLUSTER_NAME} -z us-central1-a
```

```bash
kubectl get nodes
NAME                                         STATUS   ROLES    AGE   VERSION
gke-poc-gke-dev-default-pool-5e794af1-6qz8   Ready    <none>   12m   v1.22.15-gke.100
gke-poc-gke-dev-default-pool-5e794af1-76tg   Ready    <none>   12m   v1.22.15-gke.100

kubectl get pod -A -o wide
NAMESPACE     NAME                                                    READY   STATUS    RESTARTS       AGE
kube-system   calico-node-dxqqf                                       1/1     Running   0              3m35s
kube-system   calico-node-mcvjf                                       1/1     Running   0              5m26s
kube-system   calico-node-vertical-autoscaler-74c89c5984-kzm7r        1/1     Running   0              11m
kube-system   calico-typha-5c89446448-bpc4l                           1/1     Running   0              5m4s
kube-system   calico-typha-5c89446448-wzqzn                           1/1     Running   0              4m3s
kube-system   calico-typha-horizontal-autoscaler-7dc8f785c9-bwthr     1/1     Running   0              11m
kube-system   calico-typha-vertical-autoscaler-8568cf46bf-wnbsv       1/1     Running   0              11m
kube-system   event-exporter-gke-f66d9f855-ccsxh                      2/2     Running   4              12m
kube-system   fluentbit-gke-86pp4                                     2/2     Running   0              11m
kube-system   fluentbit-gke-brjsg                                     2/2     Running   0              10m
kube-system   gke-metadata-server-w5nl9                               1/1     Running   4              11m
kube-system   gke-metadata-server-xrgtk                               1/1     Running   0              10m
kube-system   gke-metrics-agent-cdjzs                                 1/1     Running   0              10m
kube-system   gke-metrics-agent-vm98w                                 1/1     Running   0              11m
kube-system   ip-masq-agent-7tzbk                                     1/1     Running   0              10m
kube-system   ip-masq-agent-frkdc                                     1/1     Running   0              11m
kube-system   kube-dns-6ffbbcc66d-fqnf5                               4/4     Running   0              9m24s
kube-system   kube-dns-6ffbbcc66d-xgpt4                               4/4     Running   0              12m
kube-system   kube-dns-autoscaler-f4d55555-fc5ql                      1/1     Running   0              12m
kube-system   kube-proxy-gke-poc-gke-dev-default-pool-5e794af1-6qz8   1/1     Running   0              10m
kube-system   kube-proxy-gke-poc-gke-dev-default-pool-5e794af1-76tg   1/1     Running   0              10m
kube-system   l7-default-backend-7dc577646d-s2mwc                     1/1     Running   0              11m
kube-system   metrics-server-v0.4.5-fb4c49dd6-vjr9v                   2/2     Running   0              7m27s
kube-system   netd-72wsh                                              1/1     Running   0              11m
kube-system   netd-k8dx9                                              1/1     Running   0              10m
kube-system   pdcsi-node-6z6sv                                        2/2     Running   0              10m
kube-system   pdcsi-node-pkl5j                                        2/2     Running   0              11m
```
