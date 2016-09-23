# Adds a specifiec compile master to an exsiting MoM
# Usage: puppet apply -e "class add_compile_master {"

class add_compile_master (
  $mom             = $fqdn,
  $compilers       = [ "compile-01.${mom}", "compile-02.${mom}", "compile-03.${mom}" ]
){

  Exec {
  path => '/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/opt/puppetlabs/bin',
  }

  $classifier_opts  = "-s --cacert /etc/puppetlabs/puppet/ssl/certs/ca.pem --cert /etc/puppetlabs/puppet/ssl/certs/${mom}.pem --key /etc/puppetlabs/puppet/ssl/private_keys/${mom}.pem --insecure"
  $groups_endpoint  = 'https://localhost:4433/classifier-api/v1/groups'
  $filter_pe_master = ' | python -m json.tool | grep -C 2 "$1" | grep "id" | cut -d: -f2 | sed \'s/[\\", ]//g\' '

  $compilers.each |String $compiler| {

    $group_id_cmd = "group_id=\$(curl ${classifier_opts} ${groups_endpoint} ${filter_pe_master})"
    $pin_cmd      = "curl -X POST -H \'Content-Type: application/json\' -d \"{\\\"nodes\\\": [\\\"${compiler}\\\"]}\" \"https://localhost:4433/classifier-api/v1/groups/\$group_id)/pin"
    $classify_cmd = "${group_id_cmd} ; ${pin_cmd}"

    exec { "sign compiler: ${compiler}":
      path    => '/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/opt/puppetlabs/bin',
      command => "puppet cert sign ${compiler} --allow-dns-alt-names",
      user    => 'root',
      onlyif  => "test -f \"\$(puppet config print cadir)/requests/${compiler}.pem\"",
      notify  => Exec["first run ${compiler}"],
    }

    exec { "first run: ${compiler}":
      command     => "mco puppet runonce -I ${compiler}",
      user        => 'peadmin',
      refreshonly => true,
      notify      => Exec["classify: ${compiler}"],
    }

    exec { "classify: ${compiler}":
      command     => $classify_cmd,
      user        => 'root',
      refreshonly => true,
      notify      => Exec["configure: ${compiler}"],
    }

    exec { "configure: ${compiler}":
      command     => "mco puppet runonce -I ${compiler}",
      user        => 'peadmin',
      refreshonly => true,
      notify      => Exec["configure: ${mom}"]
    }

    exec { "configure: ${mom}":
      command     => "mco puppet runonce -I ${mom}",
      user        => 'peadmin',
      refreshonly => true,
    }
  
  }
}