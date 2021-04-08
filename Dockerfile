###########################################################
# Rover
###########################################################
FROM mcr.microsoft.com/vscode/devcontainers/base:ubuntu-18.04

ARG versionTerraform
ARG versionTflint
ARG versionJq
ARG versionTfsec
ARG versionTerraformDocs
ARG versionTerragrunt
ARG versionAzureCli
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID
ARG SOURCE_SOCKET=/var/run/docker-host.sock
ARG TARGET_SOCKET=/var/run/docker.sock

COPY library-scripts/*.sh /tmp/library-scripts/

# Install Azure CLI
#
# Add Azure repository
#
RUN curl -sL https://packages.microsoft.com/keys/microsoft.asc | \
    gpg --dearmor | \
    tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null && \
#
# Add Azure CLI apt repository
# Release: https://github.com/Azure/azure-cli/releases
#
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ bionic main"  | \
    tee /etc/apt/sources.list.d/azure-cli.list && \
    curl https://packages.microsoft.com/config/ubuntu/18.04/prod.list | tee /etc/apt/sources.list.d/msprod.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    azure-cli=${versionAzureCli}-1~bionic \
    # Clean up
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/library-scripts/

COPY library-scripts/*.sh /tmp/library-scripts/

# Terraform, tflint
# Release terraform: https://github.com/hashicorp/terraform/releases
# Release tflint: https://github.com/terraform-linters/tflint/releases
#
RUN bash /tmp/library-scripts/terraform-debian.sh "${versionTerraform}" "${versionTflint}" \
    # Clean up
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/library-scripts/

#
# Install terragrunt
# Release: https://github.com/gruntwork-io/terragrunt/releases
# https://github.com/gruntwork-io/terragrunt/releases/download/v0.28.19/terragrunt_linux_amd64
#
RUN echo "Installing terragrunt ${versionTerragrunt}..." && \
    curl -sSL -o /bin/terragrunt https://github.com/gruntwork-io/terragrunt/releases/download/v0.28.19/terragrunt_linux_amd64 && \
    chmod +x /bin/terragrunt

#
# Install tfsec
# Release: https://github.com/tfsec/tfsec/releases
#
RUN echo "Installing tfsec ${versionTfsec} ..." && \
    curl -sSL -o /bin/tfsec https://github.com/tfsec/tfsec/releases/download/v${versionTfsec}/tfsec-linux-amd64 && \
    chmod +x /bin/tfsec

#
# Install terraform docs
# Release: https://github.com/terraform-docs/terraform-docs/releases
#
RUN echo "Installing terraform docs ${versionTerraformDocs}..." && \
curl -sSL -o /bin/terraform-docs https://github.com/terraform-docs/terraform-docs/releases/download/v${versionTerraformDocs}/terraform-docs-v${versionTerraformDocs}-linux-amd64 && \
chmod +x /bin/terraform-docs

# Install kubectl
RUN curl -sSL -o /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl \
    && chmod +x /usr/local/bin/kubectl

# Install Helm
RUN curl -s https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash -

#
# Install jq
#
RUN echo "Installing jq ${versionJq}..." && \
    curl -L -o /usr/bin/jq https://github.com/stedolan/jq/releases/download/jq-${versionJq}/jq-linux64 && \
    chmod +x /usr/bin/jq

ARG SSH_PASSWD

ENV SSH_PASSWD=${SSH_PASSWD} \
    USERNAME=${USERNAME} \
    versionTerraform=${versionTerraform} \
    versionTflint=${versionTflint} \
    versionJq=${versionJq} \
    TF_DATA_DIR="/home/${USERNAME}/.terraform.cache" \
    TF_PLUGIN_CACHE_DIR="/home/${USERNAME}/.terraform.cache/plugin-cache"

ARG versionRover
ENV versionRover=${versionRover}

USER ${USERNAME}
WORKDIR /tf/caf

# Setting the ENTRYPOINT to docker-init.sh will configure non-root access to 
# the Docker socket if "overrideCommand": false is set in devcontainer.json. 
# The script will also execute CMD if you need to alter startup behaviors.
# ENTRYPOINT [ "/usr/local/share/docker-init.sh" ]
CMD [ "sleep", "infinity" ]