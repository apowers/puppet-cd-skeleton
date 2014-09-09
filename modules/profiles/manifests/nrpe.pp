# Profile Configuration
class profiles::nrpe () {

  include ::nrpe

  $packages = [ 'nagios-plugins' ]
  ensure_packages($packages)

  file { '/usr/bin/check_nrpe.sh':
    ensure => 'file',
    mode   => '0555',
    source => 'puppet:///modules/profiles/check_nrpe.sh',
  }

  # Host object for Shinken server
  @@shinken::config::object { $::hostname :
    object_type => 'host',
    options     => {
      'use'            => 'standard-host',
      'contact_groups' => 'admins',
      'address'        =>  $::fqdn
    }
  }

  # A check for each disk.
  $blockdevices_array = split($::blockdevices,',')
  $blockdevices_no_fd0 = delete($blockdevices_array,'fd0')
  $blockdevices_subset = delete($blockdevices_no_fd0,'sr0')
  profiles::types::nrpe_check_disk {$blockdevices_subset: }

  # Check that the NRPE server is running
  profiles::types::nrpe_check { 'check_nrpe':
    command     => 'check_procs -c 1:1024 -C nrpe',
    description => 'NRPE Server',
  }

  # Check that the NRPE port is open
  profiles::types::nrpe_check { 'check_nrpe_port':
    command     => 'check_tcp -H localhost -p 5666',
    description => 'NRPE Port',
  }

  # Check for too many blocked processes
  profiles::types::nrpe_check { 'check_blocked_processes':
    command     => 'check_procs -s Z -w 5 -c 25',
    description => 'Blocked Processes',
  }

}
