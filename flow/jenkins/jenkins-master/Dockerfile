FROM jenkins/jenkins:lts-jdk17

USER root

# Install necessary tools with minimal layers and cleanup
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg2 \
    software-properties-common \
    git \
    lsb-release && \
    # Install Docker CLI
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && \
    apt-get install -y --no-install-recommends docker-ce-cli && \
    # Cleanup to reduce image size
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    # Create directory for custom init scripts
    mkdir -p /usr/share/jenkins/ref/init.groovy.d

# Copy configuration scripts
COPY init.groovy.d/ /usr/share/jenkins/ref/init.groovy.d/
COPY jenkins.yaml /usr/share/jenkins/ref/jenkins.yaml

# Copy plugins list and install plugins
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt --verbose

# Add custom entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Set proper permissions for Docker socket access
RUN groupadd -g 999 docker && \
    usermod -aG docker jenkins

USER jenkins

# Health check
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
  CMD curl -f http://localhost:8080/jenkins/login || exit 1

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
