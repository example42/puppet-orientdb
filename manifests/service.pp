# Class: orientdb::service
#
# This class manages orientdb services
#
# == Variables
#
# Refer to orientdb class for the variables defined here.
#
# == Usage
#
# This class is not intended to be used directly.
# It's automatically included by orientdb
#
class orientdb::service inherits orientdb {

  case $orientdb::install {

    package: {
      service { 'orientdb':
        ensure     => $orientdb::manage_service_ensure,
        name       => $orientdb::service,
        enable     => $orientdb::manage_service_enable,
        hasstatus  => $orientdb::service_status,
        pattern    => $orientdb::process,
        require    => Package['orientdb'],
      }
    }

    source,puppi: {
      service { 'orientdb':
        ensure     => $orientdb::manage_service_ensure,
        name       => $orientdb::service,
        enable     => $orientdb::manage_service_enable,
        hasstatus  => $orientdb::service_status,
        pattern    => $orientdb::process,
        require    => File['orientdb.init'],
      }
      file { 'orientdb.init':
        ensure  => $orientdb::manage_file,
        path    => '/etc/init.d/orientdb',
        mode    => '0755',
        owner   => $orientdb::config_file_owner,
        group   => $orientdb::config_file_group,
        require => Class['orientdb::install'],
        notify  => $orientdb::manage_service_autorestart,
        content => template($orientdb::real_init_script_template),
        audit   => $orientdb::manage_audit,
      }
    }

    default: { }

  }


  ### Service monitoring, if enabled ( monitor => true )
  if $orientdb::bool_monitor == true {
    monitor::port { "orientdb_${orientdb::protocol}_${orientdb::port}":
      protocol => $orientdb::protocol,
      port     => $orientdb::port,
      target   => $orientdb::monitor_target,
      tool     => $orientdb::monitor_tool,
      enable   => $orientdb::manage_monitor,
    }
    monitor::process { 'orientdb_process':
      process  => $orientdb::process,
      service  => $orientdb::service,
      pidfile  => $orientdb::pid_file,
      user     => $orientdb::process_user,
      argument => $orientdb::process_args,
      tool     => $orientdb::monitor_tool,
      enable   => $orientdb::manage_monitor,
    }
  }


  ### Firewall management, if enabled ( firewall => true )
  if $orientdb::bool_firewall == true {
    firewall { "orientdb_${orientdb::protocol}_${orientdb::port}":
      source      => $orientdb::firewall_src,
      destination => $orientdb::firewall_dst,
      protocol    => $orientdb::protocol,
      port        => $orientdb::port,
      action      => 'allow',
      direction   => 'input',
      tool        => $orientdb::firewall_tool,
      enable      => $orientdb::manage_firewall,
    }
  }

}
