# Profile Configuration
class profiles::jenkins () {

  include profiles::nginx
  class { '::jenkins':
    configure_firewall => false,
  }

  jenkins::plugin { 'git': }
  jenkins::plugin { 'parameterized-trigger': }

  file { '/etc/nginx/conf.d/jenkins.conf':
    ensure => 'present',
    source => 'puppet:///modules/profiles/jenkins/jenkins.nginx',
    notify => Service['nginx'],
  }

  # Check that the Jenkins server is running
  profiles::types::nrpe_check { 'check_jenkins':
    command     => 'check_procs -c 1:1024 -C java -a jenkins',
    description => 'Jenkins Server',
  }

  # Check that the HTTP-Alt port is open
  profiles::types::nrpe_check { 'check_jenkins_port':
    command     => 'check_tcp -H localhost -p 8080',
    description => 'HTTP-Alt Port',
  }

}
