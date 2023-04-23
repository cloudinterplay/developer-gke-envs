FROM ubuntu:22.04 AS developer-gke-envs

ENV TZ=Europe/Berlin
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install --no-install-recommends apt-transport-https ca-certificates curl git gpg-agent gnupg software-properties-common -y \
  && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg > /etc/apt/trusted.gpg.d/cloud.google.gpg \
  && curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor > /etc/apt/trusted.gpg.d/hashicorp.gpg \
  && curl -sL https://baltocdn.com/helm/signing.asc | gpg --dearmor > /etc/apt/trusted.gpg.d/helm.gpg \
  && apt-add-repository "deb https://apt.kubernetes.io/ kubernetes-xenial main" \
  && apt-add-repository "deb https://packages.cloud.google.com/apt cloud-sdk main" \
  && apt-add-repository "deb https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
  && apt-add-repository "deb https://baltocdn.com/helm/stable/debian/ all main" \
  && apt-get update \
  && apt-get install --no-install-recommends vault kubectl=1.24.0-00 terraform=1.4.4-1 helm google-cloud-cli google-cloud-sdk-gke-gcloud-auth-plugin python3-pip -y \
  && setcap -r /usr/bin/vault \
  && python3 -m pip install 'ansible-core<2.12' \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /automation
