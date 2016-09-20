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
This module will create a BASH script, `autosigning.sh` and a file `autosigning.key`, 
that the Puppet Master of Masters (MoM) will use as the key and [autosigning policy executable](https://docs.puppet.com/puppet/latest/reference/ssl_autosign.html#policy-based-autosigning) to sign new agents and compile masters. 
It's a solution to the fact that [autosigning is not supported with dns_alt_names](https://tickets.puppetlabs.com/browse/SERVER-572).

## Setup
### What autosigning affects
* Creates and manages the autosigning policy executable `/opt/puppetlabs/server/autosigning.sh`.
* Creates and manages the autosigning policy executable key `/opt/puppetlabs/server/autosigning.key`.
* ini_setting `autosign` in the master section of `/etc/puppetlabs/puppet/puppet.conf`.
* Creates and manages an additional script `/opt/puppetlabs/server/add_compile_master.sh`.
* Node classification group: `PE Master` - new compile masters are pinned to this group via the classifier api.
* Puppet agent run (required when [adding new compile master](https://docs.puppet.com/pe/latest/install_multimaster.html#step-4-run-puppet-on-selected-nodes))

### Requirements
* In order to be successfully added, new compile master nodes will need to; 
-- Run `puppet agent -t` at least three times consecutively within 20 minutes of requesting their cert.

## Usage
Apply to the Master of Masters (MoM) with an optional challenge password (key):
(The command could be used to schedule refreshes of auto-generated secure keys perhaps?)
```
puppet apply -e "class { autosigning: key_content_compiler => '4d313842f4f5f4ba55cb575f56c3b9bf' }"
```

## Default Behaviour
The default behaviour of `autosigning.sh` (included as an optional epp template for the policy executable):

1. Compare `Challenge Password` (1.2.840.113549.1.9.7) with the contents of both agent and compile master keys.
2. If the agent key is matched then the script is exited with '0' to instruct the MoM to sign this node as normal.
3. If the compiler key is matched then the add_compile_master.sh script is called to;
Sign and classify the new compile master.
The script is exited with '1' to prevent the MoM from signing the node.

New nodes will need to provide the `Challenge Password` upon cert request, 
this can be enabled by populating `csr_attributes.yaml`:

```
# Autosigning key = 4d313842f4f5f4ba55cb575f56c3b9bf
mkdir -p /etc/puppetlabs/puppet
printf \
"custom_attributes:\n  \
1.2.840.113549.1.9.7: 4d313842f4f5f4ba55cb575f56c3b9bf" \
>  /etc/puppetlabs/puppet/csr_attributes.yaml 
```

## Limitations
This module does not implement the generation of tokens but could be extended or used with [danieldreier/autosign](https://forge.puppet.com/danieldreier/autosign)
