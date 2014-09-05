require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'
require 'rspec-puppet'

#require 'hiera-puppet-helper/rspec'
require 'hiera'
require 'puppet/indirector/hiera'

hosts.each do |host|
  install_puppet
end

UNSUPPORTED_PLATFORMS = ['RedHat', 'Suse','windows','AIX','Solaris']

puppet_path = '/etc/puppet/'
puppet_apply = "puppet apply -t #{puppet_path}/manifests/site.pp"

# From https://github.com/rodjek/rspec-puppet ; doesn't work
#hiera = Hiera.new(:config => '/etc/puppet/hiera.yaml')

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation
  c.confdir = puppet_path
  c.config = File.join(puppet_path, 'puppet.conf')
  c.hiera_config = File.join(puppet_path, 'hiera.yaml')

  # Configure all nodes in nodeset
  c.before :suite do
    # Install this project into /etc/puppet
    shell('rm -rf /etc/puppet')
    scp_to(master, proj_root, '/etc/puppet')
    # Install required packages
    shell('/usr/bin/gem install r10k --no-rdoc --no-ri')
    shell('/usr/bin/apt-get install -qqy git')
    # Install remote modules
    shell('cd /etc/puppet && /usr/local/bin/r10k puppetfile install')
    # Install profiles module and any local overrides
    scp_to(master, "#{proj_root}/modules", '/etc/puppet/')
    hosts.each do |host|
#      on host, puppet('module', 'install', 'puppetlabs-stdlib'), { :acceptable_exit_codes => [0,1] }
    end
  end
end

