# Profile Configuration
class profiles::jenkins () {

  include profiles::nginx
  class { '::jenkins':
    configure_firewall => false,
  }

}
