# == Class profiles::install
#
class profiles::install {

  package { $profiles::package_name:
    ensure => present,
  }
}
