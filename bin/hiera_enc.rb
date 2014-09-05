#!/usr/bin/ruby
# Takes one parameter, a hostname.
# Must return YAML or nothing.
# YAML must contain any of 'classes', 'environment', and/or 'parameters'
# and must not be defined here AND anywhere else.
#
# Output:
#{ classes => [], environment => '', parameters => { role => '', zone => '' } }.to_yaml
#

require 'yaml'
NODE_YAML_DIR='/etc/puppet/hieradata/hosts'
@node_name=ARGV[0]
@default_zone='global'
@default_environment='production'

# Load the node's hiera yaml file.
# Build a hash that Puppet ENC expects.
# Output that hash as YAML.
begin
  host_yaml = YAML.load_file("#{NODE_YAML_DIR}/#{@node_name}.yaml")

  host_data = {
    :environment => ( host_yaml['environment'] || @default_environment ),
    :parameters  => { :zone => ( host_yaml['zone'] || @default_zone ) }
  }

  # Note: classes should not be defined in the node yaml.
  if host_yaml['classes'] then host_data[:classes] = host_yaml['classes'] end

  # Remove these values so they aren't added to parameters.
  ['classes','environment','zone'].each {|value| host_yaml.delete value}

  # All other attributes are parameters.
  host_yaml.each {|param,value| host_data[:parameters][param] = host_yaml[param] }

rescue
  host_data = { :parameters => nil }
end

puts host_data.to_yaml
