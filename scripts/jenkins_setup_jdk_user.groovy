//ref. https://groups.google.com/forum/#!msg/jenkinsci-users/5CD8Y-nNLhY/z8cYq1-UBwAJ

import jenkins.model.*
import hudson.model.*
  
def inst = Jenkins.getInstance()
def desc = inst.getDescriptor("hudson.tools.JDKInstaller")
println desc.doPostCredential('YourEmailAccount','YourPassword')
