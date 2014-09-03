# == Class profiles::params
#
# This class is meant to be called from profiles
# It sets variables according to platform
#
class profiles::params {
  case $::osfamily {
    'Debian': {
      $package_name = 'profiles'
      $service_name = 'profiles'
    }
    'RedHat', 'Amazon': {
      $package_name = 'profiles'
      $service_name = 'profiles'
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }
}
