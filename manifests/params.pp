class autosigning::params {
  $policy_exe_file                  = '/opt/puppetlabs/server/autosigning.sh'
  $policy_exe_file_template         = 'autosigning/autosigning.sh.epp'
  $key_file_agent                   = '/opt/puppetlabs/server/autosigning_agent.key'
  $key_content_agent                = 'CHANGE_ME'
  $key_file_compiler                = '/opt/puppetlabs/server/autosigning_compiler.key'
  $key_content_compiler             = 'CHANGE_ME_ALSO'
  $puppet_conf_file                 = '/etc/puppetlabs/puppet/puppet.conf'
  $add_compile_master_file          = '/opt/puppetlabs/server/add_compile_master.sh'
  $add_compile_master_file_template = 'autosigning/add_compile_master.sh.epp'
}
