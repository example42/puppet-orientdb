# Class: orientdb::user
#
# This class creates orientdb user
#
# == Usage
#
# This class is not intended to be used directly.
# It's automatically included by orientdb
#
class orientdb::user inherits orientdb {
  @user { $orientdb::process_user :
    ensure     => $orientdb::manage_file,
    comment    => "${orientdb::process_user} user",
    password   => '!',
    managehome => false,
    home       => $orientdb::real_orientdb_dir,
    shell      => '/bin/bash',
    before     => Group['orientdb'] ,
  }
  @group { $orientdb::process_user :
    ensure     => $orientdb::manage_file,
  }

  User <| title == $orientdb::process_user |>
  Group <| title == $orientdb::process_user |>

}
