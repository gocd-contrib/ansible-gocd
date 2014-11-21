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
* Specify an email address for the Go administrator via GOCD_ADMIN_EMAIL.  **This is required**.
* Optionally install Git, Subversion, or Mercurial **on all agent & server nodes** by setting any of the following to true.  Default is false.
   * GOCD_SCM_GIT 
   * GOCD_SCM_SVN 
   * GOCD_SCM_MERCURIAL
   
* A bash script to support automatic backups to Git is provided in /usr/share/go-server/backup_to_git.sh
   * Create a pipeline with two materials, 'remote' for the Git backup target, and 'local' for the embedded Git repo Go uses for configuration storage.
      * Destination directories should be 'remote' and 'local' respectively
      * Require a resource of 'OnServer' to ensure that only local agents are used.  See agent autoregistration section for more details.
   * If security is enabled use ADMIN_USER and ADMIN_PASSWORD environment variables to specify security.

   * Below is a sample config of a pipeline that triggers a backup of Go every 10 minutes, or if the configuration changes. It uses SSH keys for authentication to Github as described later in this document.  It shows ADMIN_PASSWORD as a standard variable, but you should use a secure variable.
   
```XML
<pipelines group="goAdmin">
    <pipeline name="backupGo" isLocked="true">
      <timer>0 10 * * * ?</timer>
      <environmentvariables>
        <variable name="ADMIN_USER">
          <value>admin</value>
        </variable>
        <variable name="ADMIN_PASSWORD">
          <value>insecure</value>
        </variable>
      </environmentvariables>
      <materials>
        <git url="git@github.com:YourUser/YourBackupRepo" dest="remote">
          <filter>
            <ignore pattern="*" />
          </filter>
        </git>
        <git url="file:///var/lib/go-server/db/config.git" dest="local" />
      </materials>
      <stage name="defaultStage">
        <jobs>
          <job name="defaultJob">
            <tasks>
              <exec command="/bin/sh">
                <arg>/usr/share/go-server/backup_to_git.sh</arg>
              </exec>
            </tasks>
            <resources>
              <resource>OnServer</resource>
            </resources>
          </job>
        </jobs>
      </stage>
    </pipeline>
  </pipelines>
```
   
#### Optional Configuration Items
**This capability is basic now, but the goal is to support full configuration of Go via source control with no dependency on the UI.  Hopefully this will include the ability to use individual pipeline configuration files that are included in the resulting Go configuration file.**

**THIS IS A WORK IN PROGRESS: PLEASE MONITOR YOUR GO LOGS TO DETECT INVALID CHANGES**.  Sorry.

This role can manage the base Go configuration, without losing agent or pipeline definitions.  
* Enable configuration by setting GOCD_CONFIGURE to true and supply an administrator email address.
   * Required for all other configuration sections, but does nothing by itself *yet*. This will support configuring the server attributes (artifacts dir, command repository location, etc.) in the future.
   * GOCD_ADMIN_EMAIL - Email address for the system administrator
   
* SMTP/E-Mail notificationss
   * Set GOCD_CONFIGURE_SMTP to true and set appropriate values for the below variables:
      * GOCD_SMTP_HOST - IP address or hostname of the SMTP server
      * GOCD_SMTP_FROM_ADDR - Email address notifications are sent from
      * GOCD_SMTP_USER [optional] - Username for authentication to the SMTP server
      * GOCD_SMTP_PASSWORD - Password for SMTP authentication. Go will encrypt it and remove the unencrypted entry.
      * GOCD_SMTP_ENCRYPTED_PASSWORD - Encrypted password for SMTP authentication.  *One of the two password is required if a SMTP user is defined.*
      * GOCD_SMTP_TLS [optional] - Use TLS when sending email.  Default is true.

* User Security
   * Set GOCD_CONFIGURE_SECURITY to true and optionally define LDAP configure.  By default an admin user of 'admin' with a password of 'insecure' will be created in /etc/go/passwd.
   * For LDAP authentication specify values for GOCD_LDAP_URL, GOCD_LDAP_MANAGER_DN, GOCD_LDAP_SEARCH_FILTER, and GOCD_LDAP_SEARCH_BASE. See Go's documentation on how to use these.
   * The default admin username, password, and file path can be overridden with GOCD_DEFAULT_ADMIN, GOCD_DEFAULT_PASS, and GOCD_PASSWORDFILE_PATH
   
* SSH keys.  This is primarily for Github SSH access.  Specify a keypair via attributes. The keys will be identical on all agents as well as the server.  This is because the server monitors for changes, and agents actually handle the checkout.
  * Set GOCD_CONFIGURE_SSH to true
  * GOCD_SSH_PRIVATE_KEY - Fully qualified path to the private key to use.  Both will be stored in /var/go/.ssh.  
  * GOCD_SSH_PUBLIC_KEY - Fully qualified path to the public key.  This is the key you should upload to Github.
  * GOCD_SSH_KNOWN_DOMAIN - Domain to import as a known host, defaults to github.com but can override for internal git servers.
  
### Agents
* By default one agent will be installed per CPU core available.  You can override this by setting GOCD_AGENT_INSTANCES to a specific value.
* When multiple agents are installed each is controlled by it's own service (/etc/init.d/go-agentX). If you wish to uninstall the package, you'll need to manually remove those services as they're not recognized by the RPM/DEB.
* Agents default to automatic registration with the server using an insecure key.  Override GOCD_AUTO_REGISTER_KEY with something appropriate.
   * Agents are automatically tagged with default resources as appropriate.  These include Linux distribution ("Fedora"), distribution with version ("Fedora-20"), platform ("Linux"), java, and java version ("java-1.7.0_65").  A special resource "OnServer" identifies agents that coexist on the same node as the Go server.

## developing
Fork away!  Pull requests are always appreciated. :-)

You should be able to do a vagrant up and have a running instance of this role.  Take a look inside Vagrantfile and you'll notice we're forcing a role_path on Ansible.  

It's been tested on Vagrant 1.5.1 thru 1.6.5 with VirtualBox primarily, with a little attention paid to Docker.
