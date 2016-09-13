class autosigning::params {
  $policy_exe_file                 = '/etc/puppetlabs/puppet/autosigning.sh'
  $policy_exe_file_content         = template('autosigning/autosigning.sh.erb')
  $key_file                        = '/etc/puppetlabs/puppet/autosigning.key'
  $key_content                     = 'CHANGE_ME'
  $puppet_conf_file                = '/etc/puppetlabs/puppet/puppet.conf'
  $add_compile_master_file         = '/etc/puppetlabs/puppet/add_compile_master.sh'
  $add_compile_master_file_content = template('autosigning/add_compile_master.sh.erb')
}
