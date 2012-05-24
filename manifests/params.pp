# Class: orientdb::params
#
# This class defines default parameters used by the main module class orientdb
# Operating Systems differences in names and paths are addressed here
#
# == Variables
#
# Refer to orientdb class for the variables defined here.
#
# == Usage
#
# This class is not intended to be used directly.
# It may be imported or inherited by other classes
#
class orientdb::params {

  ### Module specific parameters
  $root_password = ''
  $guest_password = 'guest'
  $replicator_password = ''
  $admin_password = 'admin'
  $version = ''
  $install = 'source'
  $install_precommand = ''
  $install_postcommand = ''
  $init_script_template = ''

  ### Application related parameters

  $package = $::operatingsystem ? {
    default => 'orientdb',
  }

  $service = $::operatingsystem ? {
    default => 'orientdb',
  }

  $service_status = $::operatingsystem ? {
    default => true,
  }

  $process = $::operatingsystem ? {
    default => 'java',
  }

  $process_args = $::operatingsystem ? {
    default => 'orientdb',
  }

  $process_user = $::operatingsystem ? {
    default => 'orientdb',
  }

  $config_file_mode = $::operatingsystem ? {
    default => '0644',
  }

  $config_file_owner = $::operatingsystem ? {
    default => 'root',
  }

  $config_file_group = $::operatingsystem ? {
    default => 'root',
  }

  $pid_file = $::operatingsystem ? {
    default => '/var/run/orientdb.pid',
  }

  $data_dir = $::operatingsystem ? {
    default => '/var/lib/orientdb',
  }

  $log_dir = $::operatingsystem ? {
    default => '/var/log/orientdb',
  }

  $log_file = $::operatingsystem ? {
    default => '/var/log/orientdb/orient-server.log.0',
  }

  $port = '2424'
  $protocol = 'tcp'

  # General Settings
  $my_class = ''
  $source = ''
  $source_dir = ''
  $source_dir_purge = ''
  $template = ''
  $options = ''
  $absent = false
  $disable = false
  $disableboot = false

  ### General module variables that can have a site or per module default
  $monitor = false
  $monitor_tool = ''
  $monitor_target = $::ipaddress
  $puppi = false
  $puppi_helper = 'java'
  $firewall = false
  $firewall_tool = ''
  $firewall_src = '0.0.0.0/24'
  $firewall_dst = $::ipaddress
  $debug = false
  $audit_only = false

}
