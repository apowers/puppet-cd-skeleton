# Abstract nrpe check for disks
# Referenced by sbri::services::shinken_agent
define profiles::types::nrpe_check (
  $command      = undef,
  $description  = $name,
) {
  validate_string($command)
  if defined('nrpe') {
    nrpe::plugin { $name:
      plugin => $command,
      tag    => "nrpe_${::hostname}",
    }

    @@shinken::config::object { "${name}_${::hostname}":
      object_type => 'service',
      options     => {
        'host_name'           => $::fqdn,
        'service_description' => $description,
        'use'                 => 'standard-service',
        'check_command'       => "check_nrpe_poller!${name}",
      }
    }
  } else {
    notify { 'WARNING: Failed to create an NRPE check because ::nrpe is not defined': }
  }

}
