# Import hiera data for a role
shared_context "initializer" do |role|
  let(:hiera_config) { File.expand_path(File.join(File.dirname(__FILE__), '../hiera.yaml')) }
  let(:hiera) { Hiera.new(:config => hiera_config) }
  let(:manifest) { '
    hiera_include("classes")
    Service {provider=>"init"}
  '}
  let(:puppet_apply_cmd) { 'puppet apply --detailed-exitcodes /etc/puppet/manifests/site.pp' }
end
