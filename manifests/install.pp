# Class: orientdb::install
#
# This class installs orientdb
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
class orientdb::install inherits orientdb {

  case $orientdb::install {

    package: {
      package { 'orientdb':
        ensure => $orientdb::manage_package,
        name   => $orientdb::package,
      }
    }

    source: {

      $created_dirname = url_parse($orientdb::real_install_source,'filedir')

      require orientdb::user

      # Source zip does not contain a single parent dir :-I
      file { 'orientdb_dir':
        ensure => directory ,
        path   => "${orientdb::real_install_destination}/${created_dirname}" ,
      }

      puppi::netinstall { 'netinstall_orientdb':
        url                 => $orientdb::real_install_source,
        destination_dir     => "${orientdb::real_install_destination}/${created_dirname}" ,
        preextract_command  => $orientdb::install_precommand,
        postextract_command => "chown -R ${orientdb::process_user}:${orientdb::process_user} ${orientdb::real_install_destination}/${created_dirname}",
        extracted_dir       => 'databases',
        owner               => $orientdb::process_user,
        group               => $orientdb::process_user,
        require             => [ File['orientdb_dir'] , User[$orientdb::process_user] ],
      }

      file { 'orientdb_link':
        ensure => "${orientdb::real_install_destination}/${created_dirname}" ,
        path   => $orientdb::real_orientdb_dir ,
      }

    }

    puppi: {

      require orientdb::user

      puppi::project::archive { 'orientdb':
        source                   => $orientdb::real_install_source,
        deploy_root              => $orientdb::real_install_destination,
        predeploy_customcommand  => $orientdb::install_precommand,
        postdeploy_customcommand => $orientdb::install_postcommand,
        report_email             => 'root',
        user                     => $orientdb::process_user,
        auto_deploy              => true,
        enable                   => true,
        require                  => User[$orientdb::process_user],
      }

    }

    default: { }

  }

}
