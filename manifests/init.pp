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
#
class autosigning (
  $policy_exe_file                 = $autosigning::params::policy_exe_file,
  $policy_exe_file_content         = $autosigning::params::policy_exe_file_content,
  $key_file                        = $autosigning::params::key_file,
  $key_content                     = $autosigning::params::key_content,
  $puppet_conf_file                = $autosigning::params::puppet_conf_file,
  $add_compile_master_file         = $autosigning::params::add_compile_master_file,
  $add_compile_master_file_content = $autosigning::params::add_compile_master_file_content,
) inherits ::autosigning::params {

  file { $policy_exe_file:
    ensure  => file,
    content => $policy_exe_file_content,
    mode    => '0500',
    owner   => 'pe-puppet',
    require => File[$key_file],
  }

  file { $key_file:
    ensure  => file,
    content => $key_content,
    mode    => '0600',
    owner   => 'pe-puppet',
  }

  file { $add_compile_master_file:
    ensure  => file,
    content => $add_compile_master_file_content,
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
    notify  => Service['pe-puppetserver'],
  }

}
