# Auxiliary container file
FROM registry.access.redhat.com/ubi9:9.7

# WebLogic Deployment Tool (WDT) version argument
ARG \
  WDT_VERSION=4.4.3

# Prepare the directory for the required files
RUN \
  mkdir -p /tmp/install /auxiliary/models /auxiliary/weblogic-deploy

# Copy the deployment artifact and model files into container image
ADD deployments/wlsdeploy.zip /auxiliary/models
COPY model/* /auxiliary/models

# Download and extract the WDT from GitHub
RUN curl -L -o /tmp/install/weblogic-deploy.tar.gz https://github.com/oracle/weblogic-deploy-tooling/releases/download/release-$WDT_VERSION/weblogic-deploy.tar.gz \
    && tar -xzf /tmp/install/weblogic-deploy.tar.gz -C /auxiliary/ && \
      find /auxiliary/weblogic-deploy -name '*.sh' -exec chmod 775 {} \;

USER 0

# Change the directory privileges
RUN \
  chown -R 1000:0 /auxiliary \
  && \
  chmod 775 -R /auxiliary /auxiliary/models /auxiliary/weblogic-deploy \
  && \
  rm -rf /tmp/install

# Set few environment variables
ENV \
  AUXILIARY_IMAGE_PATH=/auxiliary \
  WDT_HOME=/auxiliary \
  WDT_MODEL_HOME=/auxiliary/models

USER 1000

# Set the working directory
WORKDIR /auxiliary

CMD /bin/bash