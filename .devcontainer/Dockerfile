FROM ubuntu:22.04 AS developer-gke-envs
RUN apt-get update && apt-get install apt-transport-https ca-certificates curl git gpg-agent gnupg software-properties-common zip -y \
  && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg > /etc/apt/trusted.gpg.d/cloud.google.gpg \
  && apt-add-repository "deb https://packages.cloud.google.com/apt cloud-sdk main" \
  && curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add - \
  && apt-add-repository "deb https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
  && curl -LO https://releases.hashicorp.com/terraform/1.3.3/terraform_1.3.3_linux_arm64.zip \
  && curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | tee /usr/share/keyrings/helm.gpg > /dev/null \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list \
  && unzip terraform_1.3.3_linux_arm64.zip \
  && mv terraform /usr/bin/ \
  && apt-get update \
  && apt-get install vault kubectl helm google-cloud-cli google-cloud-sdk-gke-gcloud-auth-plugin python3-pip -y \
  && setcap -r /usr/bin/vault \
  && python3 -m pip install 'ansible-core<2.12'

WORKDIR /automation
