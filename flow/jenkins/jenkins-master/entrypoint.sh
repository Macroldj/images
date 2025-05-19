#!/bin/bash
set -e

# If the JENKINS_ADMIN_ID and JENKINS_ADMIN_PASSWORD environment variables are set,
# create a default admin user
if [ -n "$JENKINS_ADMIN_ID" ] && [ -n "$JENKINS_ADMIN_PASSWORD" ]; then
  echo "Creating admin user: $JENKINS_ADMIN_ID"
  mkdir -p /var/jenkins_home/init.groovy.d
  cat > /var/jenkins_home/init.groovy.d/basic-security.groovy << EOF
import jenkins.model.*
import hudson.security.*
import jenkins.install.InstallState

def instance = Jenkins.getInstance()
def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount("$JENKINS_ADMIN_ID", "$JENKINS_ADMIN_PASSWORD")
instance.setSecurityRealm(hudsonRealm)

def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
strategy.setAllowAnonymousRead(false)
instance.setAuthorizationStrategy(strategy)

instance.setInstallState(InstallState.INITIAL_SETUP_COMPLETED)
instance.save()
EOF
fi

# Execute the original Jenkins entrypoint
exec /usr/local/bin/jenkins.sh "$@"
