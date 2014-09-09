require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'
require 'rspec-puppet'

#require 'hiera-puppet-helper/rspec'
require 'hiera'
require 'puppet/indirector/hiera'

UNSUPPORTED_PLATFORMS = ['RedHat', 'Suse','windows','AIX','Solaris']

proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
puppet_path = '/etc/puppet/'
@puppet_apply_cmd = "puppet apply -t #{puppet_path}manifests/site.pp"
@nrpe_check_cmd = '/usr/bin/check_nrpe.sh'

hosts.each do |host|
  install_puppet
  install_package host, 'wget'
end

# This is supplimental provisioning for a master or stand-alone test system
# Install this project into /etc/puppet
on master,  shell('rm -rf /etc/puppet')
scp_to(master, proj_root, '/etc/puppet')
# Install required packages
install_package master, 'git'
on master,  shell('/usr/bin/gem install r10k --no-rdoc --no-ri')
# Install remote modules
on master,  shell('cd /etc/puppet && /usr/local/bin/r10k puppetfile install')
# Install profiles module and any local overrides
scp_to(master, "#{proj_root}/modules", '/etc/puppet/')

# Perform an initial puppet run.
puppet_apply('-t /etc/puppet/manifests/site.pp')

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation
#  c.confdir = puppet_path
#  c.config = File.join(puppet_path, 'puppet.conf')
#  c.hiera_config = File.join(puppet_path, 'hiera.yaml')

  # Configure all nodes in nodeset
  c.before :suite do
    hosts.each do |host|
      # Perform an initial puppet run.
      on host, puppet_apply('-t /etc/puppet/manifests/site.pp'), :acceptable_exit_codes => [0,1,2,3,4]
    end
  end
end

