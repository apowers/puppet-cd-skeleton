# Profile Configuration
class profiles::puppet (
  $puppetmaster   = 'puppet',
  $environment    = 'production',
  $version        = 'latest',
  $autosign       = false,
  $reports        = 'log',
) {

  include ::puppet

  apt::source { 'puppetlabs':
    location   => 'http://apt.puppetlabs.com',
    repos      => 'main dependencies',
    key        => '1054B7A24BD6EC30',
    key_server => 'pgp.mit.edu',
  }

  file { '/var/lib/puppet':
    owner => 'puppet',
    group => 'puppet',
    mode  => '0755',
  }

  # For Monitoring and Testing - Shinken
  # ==========================
  profiles::types::nrpe_check { 'check_puppet':
    command     => 'check_procs -c 1:1024 -C puppet -a agent',
    description => 'Puppet Agent',
  }
  # Better puppet checks
  exec { 'wget_check_puppet':
    command => '/usr/bin/wget -O /usr/lib/nagios/plugins/check_puppet https://raw.githubusercontent.com/ripienaar/monitoring-scripts/master/puppet/check_puppet.rb',
    creates => '/usr/lib/nagios/plugins/check_puppet',
    require => Package['nagios-plugins'],
  } ->
  file { '/usr/lib/nagios/plugins/check_puppet': mode  => '0555' }
  profiles::types::nrpe_check { 'check_puppet_lastrun':
    command     => 'check_puppet -w 2700 -c 9000',
    description => 'Puppet Last Run',
  }
  profiles::types::nrpe_check { 'check_puppet_errors':
    command     => 'check_puppet -w 1 -c 1 -f',
    description => 'Puppet Run Errors',
  }


}
