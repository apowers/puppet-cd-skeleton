# == Class: profiles
#
# Full description of class profiles here.
#
# === Parameters
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#
class profiles (
  $package_name = $profiles::params::package_name,
  $service_name = $profiles::params::service_name,
) inherits profiles::params {

  # validate parameters here

  class { 'profiles::install': } ->
  class { 'profiles::config': } ~>
  class { 'profiles::service': } ->
  Class['profiles']
}
