# Abstract nrpe check for disks
# Referenced by sbri::services::shinken_agent
define profiles::types::nrpe_check_disk ( ) {
  if defined('nrpe') {
    nrpe::plugin { "check_disk_${name}":
      plugin => "check_disk -w 20% -c 10% -x ${name}",
      tag    => "nrpe_${::hostname}",
    }

    @@shinken::config::object { "check_disk_${name}_${::hostname}":
      object_type => 'service',
      options     => {
        'host_name'           => $::fqdn,
        'service_description' => 'Disk Capacity',
        'use'                 => 'standard-service',
        'check_command'       => "check_nrpe_poller!check_disk_${name}",
      }
    }
  } else {
    notify { 'WARNING: Failed to create an NRPE check because ::nrpe is not defined': }
  }
}
