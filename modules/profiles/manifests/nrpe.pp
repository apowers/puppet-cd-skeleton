# Profile Configuration
class profiles::nrpe () {

  include ::nrpe

  file { '/usr/bin/check_nrpe.sh':
    ensure => 'file',
    mode   => '0555',
    source => 'puppet:///modules/profiles/check_nrpe.sh',
  }

}
