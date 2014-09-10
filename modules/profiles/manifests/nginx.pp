# Profile Configuration
class profiles::nginx () {

  include ::nginx

  # Check that the Nginx server is running
  profiles::types::nrpe_check { 'check_nginx':
    command     => 'check_procs -c 1:1024 -C nginx',
    description => 'Nginx Server',
  }

  # Check that the HTTP port is open
  profiles::types::nrpe_check { 'check_http_port':
    command     => 'check_http -H localhost',
    description => 'HTTP Connection',
  }


}
