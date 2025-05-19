import jenkins.model.*
import hudson.security.*
import jenkins.security.s2m.AdminWhitelistRule

// Enable agent to master security subsystem
Jenkins.instance.getInjector().getInstance(AdminWhitelistRule.class).setMasterKillSwitch(false)

// Enable CSRF protection
def instance = Jenkins.instance
def crumb = instance.getCrumbIssuer()
if (crumb == null) {
    def desc = instance.getDescriptor("hudson.security.csrf.DefaultCrumbIssuer")
    crumb = new hudson.security.csrf.DefaultCrumbIssuer(true)
    instance.setCrumbIssuer(crumb)
    println "CSRF protection enabled"
}

// Disable CLI over Remoting
Jenkins.instance.getDescriptor("jenkins.CLI").get().setEnabled(false)

// Disable old agent protocols
Set<String> agentProtocolsList = ['JNLP4-connect', 'Ping']
Jenkins.instance.setAgentProtocols(agentProtocolsList)
println "Agent protocols set to: ${agentProtocolsList}"

// Save the configuration
instance.save()
