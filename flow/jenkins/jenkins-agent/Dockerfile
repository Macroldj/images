FROM jenkins/inbound-agent:latest-jdk17

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
    maven \
    python3 \
    python3-pip \
    nodejs \
    npm \
    lsb-release && \
    # Install Docker CLI
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && \
    apt-get install -y --no-install-recommends docker-ce-cli && \
    # Cleanup to reduce image size
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create working directory with proper permissions
RUN mkdir -p /var/jenkins_agent && \
    chown -R jenkins:jenkins /var/jenkins_agent

# Set proper permissions for Docker socket access
RUN groupadd -g 999 docker && \
    usermod -aG docker jenkins

WORKDIR /var/jenkins_agent

USER jenkins
