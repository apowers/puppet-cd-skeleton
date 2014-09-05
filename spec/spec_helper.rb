require 'puppetlabs_spec_helper/module_spec_helper'

puppet_path = File.expand_path(File.join(File.dirname(__FILE__), '..'))

RSpec.configure do |c|
  c.confdir = puppet_path
  c.config = File.join(puppet_path, 'puppet.conf')
  c.hiera_config = File.join(puppet_path, 'hiera.yaml')
  c.default_facts = {
    :osfamily         => 'Debian',
    :lsbdistid        => 'Ubuntu',
    :kernel           => 'Linux',
    :lsbdistcodename  => 'trusty',
  }
end


