require 'puppetlabs_spec_helper/module_spec_helper'

fixture_path = File.expand_path(File.join(__FILE__, '..', 'fixtures'))
puppet_path  = File.expand_path(__FILE__, '../../..')

RSpec.configure do |c|
#  c.confdir = puppet_path
#  c.config = File.join(puppet_path, 'puppet.conf')
#  c.hiera_config = File.join(puppet_path, 'hiera.yaml')
#  c.manifest = File.join(puppet_path, 'manifests/site.pp')
  c.module_path = File.join(fixture_path, 'modules')
  c.manifest_dir = File.join(fixture_path, 'manifests')
  c.default_facts = {
    :osfamily         => 'Debian',
    :lsbdistid        => 'Ubuntu',
    :kernel           => 'Linux',
    :lsbdistcodename  => 'trusty',
  }
end


