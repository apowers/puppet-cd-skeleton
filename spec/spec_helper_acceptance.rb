require 'beaker-rspec'
require 'beaker-rspec/helpers/serverspec'
require 'rspec-puppet'
require 'puppetlabs_spec_helper/module_spec_helper'
#require 'puppetlabs_spec_helper/puppet_spec_helper'

require 'hiera'
require 'pry'
require 'hiera-puppet-helper/rspec'
#require 'puppet/indirector/hiera'

# Include class behavior tests for roles
#Dir["./spec/classes/**/*.rb"].sort.each {|f| require f}
# This didn't work
# Instead put them in acceptance/00_$(name)_spec.rb where they will be autoloaded before role tests.

UNSUPPORTED_PLATFORMS = ['RedHat', 'Suse','windows','AIX','Solaris']

proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
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

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation
  c.hiera_config = File.join(proj_root, 'hiera.yaml')
  c.manifest_dir = File.join(proj_root, 'manifests')
  c.module_path = File.join(proj_root, 'modules')

  # Configure all nodes in nodeset
  c.before :suite do
    hosts.each do |host|
      # Perform an initial puppet run.
#      on host, puppet_apply('/etc/puppet/manifests/site.pp'), :acceptable_exit_codes => [0,1,2,3,4]
    end
  end
end

