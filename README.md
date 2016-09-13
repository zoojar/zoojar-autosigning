# zoojar-autosigning
#### Table of Contents

1. [Overview](#overview)
2. [Description](#description)
3. [Setup](#setup)
4. [Usage](#usage)
5. [Limitations](#limitations)

## Overview
Configures autosigning on a master of masters to autosign both agents and compile masters.

## Description
This module will create a BASH script, `autosigning.sh` and a file `autosigning.key`, that the Puppet Master of Masters (MoM) will use as the key and [autosigning policy executable](https://docs.puppet.com/puppet/latest/reference/ssl_autosign.html#policy-based-autosigning) to sign new agents and compile masters. It's a solution to the fact that [autosigning is not supported with dns_alt_names](https://tickets.puppetlabs.com/browse/SERVER-572).

## Setup
### What autosigning affects
* Creates and manages the autosigning policy executable `/etc/puppetlabs/puppet/autosigning.sh`.
* Creates and manages the autosigning policy executable key '/etc/puppetlabs/puppet/autosigning.key`.
* ini_setting `autosign` in the master section of `/etc/puppetlabs/puppet/puppet.conf`.
* Creates and manages an additional script `/etc/puppetlabs/puppet/add_compile_master.sh`.
* Node classification group: `PE Master` - new compile masters are pinned to this group via the classifier api.
* Puppet agent run (required when [adding new compile master](https://docs.puppet.com/pe/latest/install_multimaster.html#step-4-run-puppet-on-selected-nodes))

### Requirements
* For a setup with a MoM and additional compile masters `dns_alt_names` must be configured in `/etc/puppetlabs/puppet/puppet.conf`.
* In order to be successfully added, new compile master nodes will need to consecutively run `puppet agent -t` at least three times within 15 minutes of requesting their cert.

## Usage
Classify the Master of Masters (MoM):
```
include ::autosigning
```

## Default Behaviour
The default behaviour of `autosigning.sh` is:

1. Check the certname of the new node against the the MoM's configured dns_alt_names - if a match exists then the compile master is signed and classified using an additional external script and the autosigning.sh script is not used (policy exe exits with 1 to instrict the master not to sign this node - [autosigning is not supported with dns_alt_names](https://tickets.puppetlabs.com/browse/SERVER-572)).

2. Compare `Challenge Password` (1.2.840.113549.1.9.7) with the contents of `global-psk` to authorize the node.
New nodes will need to provide the `Challenge Password` upon cert request, this can be enabled by populating `csr_attributes.yaml`:

```
# Autosigning key = 4d313842f4f5f4ba55cb575f56c3b9bf
mkdir -p /etc/puppetlabs/puppet
printf "custom_attributes:\n  1.2.840.113549.1.9.7: 4d313842f4f5f4ba55cb575f56c3b9bf" >  /etc/puppetlabs/puppet/csr_attributes.yaml 
```

## Limitations
This module does not implement the generation of tokens but could be extended or used with [danieldreier/autosign](https://forge.puppet.com/danieldreier/autosign)
