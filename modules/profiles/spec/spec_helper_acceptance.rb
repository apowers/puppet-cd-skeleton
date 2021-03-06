require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'

hosts.each do |host|
  # Install Puppet
  install_puppet
end

UNSUPPORTED_PLATFORMS = ['RedHat', 'Suse','windows','AIX','Solaris']

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install this project at /etc/puppet
    shell('rm -rf /etc/puppet')
    scp_to(master, proj_root, '/etc/puppet')
    # Install required packages
    shell('/usr/bin/gem install r10k --no-rdoc --no-ri')
    shell('/usr/bin/apt-get install -qqy git')
    # Install remote modules
    shell('cd /etc/puppet&&/usr/local/bin/r10k puppetfile install')
    hosts.each do |host|
#      on host, puppet('module', 'install', 'puppetlabs-stdlib'), { :acceptable_exit_codes => [0,1] }
    end
  end
end

