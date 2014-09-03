# == Class profiles::service
#
# This class is meant to be called from profiles
# It ensure the service is running
#
class profiles::service {

  service { $profiles::service_name:
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }
}
