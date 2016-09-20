# Class: autosigning
# 
# Parameters
# ----------
#
# * `policy_exe_file_content` 
#   Default: erb template containing policy executable (bash script)
#
# * `add_compile_master_file_content`
#   Default: erb template containing bash script to sign, classify and add a new compile master
#   - this script is called by the autosigning.sh script upon node cert request.
#

class autosigning (
  $policy_exe_file                  = $autosigning::params::policy_exe_file,
  $policy_exe_file_template         = $autosigning::params::policy_exe_file_template,
  $key_file_agent                   = $autosigning::params::key_file_agent,
  $key_content_agent                = $autosigning::params::key_content_agent,
  $key_file_compiler                = $autosigning::params::key_file_compiler,
  $key_content_compiler             = $autosigning::params::key_content_compiler,
  $puppet_conf_file                 = $autosigning::params::puppet_conf_file,
  $add_compile_master_file          = $autosigning::params::add_compile_master_file,
  $add_compile_master_file_template = $autosigning::params::add_compile_master_file_template,
) inherits ::autosigning::params {

  file { $policy_exe_file:
    ensure  => file,
    content => epp($policy_exe_file_template),
    mode    => '0500',
    owner   => 'pe-puppet',
    require => File[$key_file_agent,$key_file_compiler],
  }

  file { $key_file_agent:
    ensure  => file,
    content => $key_content_agent,
    mode    => '0600',
    owner   => 'pe-puppet',
  }
  
  file { $key_file_compiler:
    ensure  => file,
    content => $key_content_compiler,
    mode    => '0600',
    owner   => 'pe-puppet',
  }

  file { $add_compile_master_file:
    ensure  => file,
    content => epp($add_compile_master_file_template),
    mode    => '0500',
    owner   => 'pe-puppet',
    before  => File[$policy_exe_file],
  }

  ini_setting { "autosign ${policy_exe_file}":
    ensure  => present,
    path    => $puppet_conf_file,
    section => 'master',
    setting => 'autosign',
    value   => $policy_exe_file,
    require => File[$policy_exe_file],
  }

  service { 'pe-puppetserver':
    ensure    => running,
    subscribe => Ini_setting["autosign ${policy_exe_file}"],
  }

}
