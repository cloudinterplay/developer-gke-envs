FROM ubuntu:22.04 AS developer-gke-envs

ENV TZ=Europe/Berlin
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install --no-install-recommends apt-transport-https ca-certificates curl git gpg-agent gnupg lsb-release -y \
  && curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.27/deb/Release.key | gpg --dearmor > /etc/apt/keyrings/kubernetes-apt-keyring.gpg \
  && echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.27/deb/ /' | tee /etc/apt/sources.list.d/kubernetes.list \
  && curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor > /usr/share/keyrings/hashicorp-archive-keyring.gpg \
  && echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list \
  && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | tee /usr/share/keyrings/cloud.google.asc \
  && echo "deb [signed-by=/usr/share/keyrings/cloud.google.asc] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list \
  && apt-get update \
  && apt-get install --no-install-recommends kubectl=1.27.7-1.1 terraform=1.5.5-1 google-cloud-cli google-cloud-sdk-gke-gcloud-auth-plugin python3-pip -y \
  && python3 -m pip install 'ansible-core<2.14' \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /automation
