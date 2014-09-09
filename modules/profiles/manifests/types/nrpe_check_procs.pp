# Abstract nrpe check for processes
# Referenced by sbri::services::shinken_agent
define profiles::types::nrpe_check_procs (
  $description = "${name} Processes",
) {
  if defined('nrpe') {
    nrpe::plugin { "check_procs_${name}":
      plugin => "check_procs -c 1:1024 -C ${name}",
      tag    => "nrpe_${::hostname}",
    }
    @@shinken::config::object { "check_procs_${name}_${::hostname}":
      object_type => 'service',
      options     => {
        'host_name'           => $::fqdn,
        'service_description' => $description,
        'use'                 => 'standard-service',
        'check_command'       => "check_nrpe_poller!check_procs_${name}",
      }
    }
  } else {
    notify { 'WARNING: Failed to create an NRPE check because ::nrpe is not defined': }
  }
}
