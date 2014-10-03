[![Snap-CI](https://snap-ci.com/Tpbrown/ansible-gocd/branch/master/build_image)](https://snap-ci.com/Tpbrown/ansible-gocd/)
ATTENTION: 
=
This repository was recently transferred from ThoughtWorksInc to Tpbrown.  If you've forked it you'll need to update your remotes (or delete & re-fork). 

Apologies for the change -- it was adding confusion around support. (It's not supported ;-)



ansible-gocd
=============

Ansible Playbook to install Go.  

Model even the most complex build & deploy workflow with ease. Unlike CI servers, Go was built from the ground up with pipelines in mind. Go makes it simple to model failing fast, artifact promotion, self-service environments and single-click deployment.

Product details are available at http://www.go.cd .  Source available at https://github.com/GoCD/GoCD

requirements
============
* Ansible 1.6+ is required for UFW firewall module support.  
* Ansible 1.5 can be used if you comment out the UFW tasks.

installation instructions
=========================

This repository is organized as a single Role. That means it can be included, symlinked, submoduled, or galaxied into your existing Ansible repository. 

The default is to install the latest version of the server and agents onto a single node.  Use the tags of 'server' or 'agent' to selectively install one or the other.

To force installation of a specific version override GOCD_GO_VERSION to the desired version.
### Server
* The server listens on port 8153 by default.  
* Optionally install Git, Subversion, or Mercurial **on all agent & server nodes** by setting any of the following to true.  Default is false.
   * GOCD_SCM_GIT 
   * GOCD_SCM_SVN 
   * GOCD_SCM_MERCURIAL
   
#### Optional Configuration Items
**This capability is basic now, but the goal is to support full configuration of Go via source control with no dependency on the UI.  Hopefully this will include the ability to use individual pipeline configuration files that are included in the resulting Go configuration file.**

**THIS IS A WORK IN PROGRESS: PLEASE MONITOR YOUR GO LOGS TO DETECT INVALID CHANGES**.  Sorry.

This role can manage the base Go configuration, without losing agent or pipeline definitions.  
* Enable configuration by setting GOCD_CONFIGURE to true
   * Required for all other configuration sections, but does nothing by itself *yet*. This will support configuring the server attributes (artifacts dir, command repository location, etc.) in the future.

* Configure SMTP/E-Mail support for notifications
   * Set GOCD_CONFIGURE_SMTP to true and set appropriate values for the below variables:
      * GOCD_SMTP_HOST - IP address or hostname of the SMTP server
      * GOCD_SMTP_FROM_ADDR - Email address notifications are sent from
      * GOCD_SMTP_ADMIN_ADDR - Email address for the system administrator
      * GOCD_SMTP_USER [optional] - Username for authentication to the SMTP server
      * GOCD_SMTP_PASSWORD - Password for SMTP authentication. Go will encrypt it and remove the unencrypted entry.
      * GOCD_SMTP_ENCRYPTED_PASSWORD - Encrypted password for SMTP authentication.  *One of the two password is required if a SMTP user is defined.*
      * GOCD_SMTP_TLS [optional] - Use TLS when sending email.  Default is true.

* Configure Security
   * Set GOCD_CONFIGURE_SECURITY to true and optionally define LDAP configure.  By default an admin user of 'admin' with a password of 'insecure' will be created in /etc/go/passwd.
   * For LDAP authentication specify values for GOCD_LDAP_URL, GOCD_LDAP_MANAGER_DN, GOCD_LDAP_SEARCH_FILTER, and GOCD_LDAP_SEARCH_BASE. See Go's documentation on how to use these.
   * The default admin username, password, and file path can be overridden with GOCD_DEFAULT_ADMIN, GOCD_DEFAULT_PASS, and GOCD_PASSWORDFILE_PATH

  
### Agents
* By default one agent will be installed per CPU core available.  You can override this by setting GOCD_AGENT_INSTANCES to a specific value.
* When multiple agents are installed each is controlled by it's own service (/etc/init.d/go-agentX). If you wish to uninstall the package, you'll need to manually remove those services as they're not recognized by the RPM/DEB.

## developing
Fork away!  Pull requests are always appreciated. :-)

You should be able to do a vagrant up and have a running instance of this role.  Take a look inside Vagrantfile and you'll notice we're forcing a role_path on Ansible.  

It's been tested on Vagrant 1.5.1 thru 1.6.3 with VirtualBox primarily, with a little attention paid to Docker on Linux via the docker-provider plugin.
