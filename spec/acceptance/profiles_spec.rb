require 'spec_helper_acceptance'

# Include class behavior tests for roles
Dir["./spec/classes/**/*.rb"].sort.each {|f| require f}

describe 'puppet apply' do
  context 'with no role' do
    let(:facts) {{ :role => 'none' }}
#    manifest = "class { 'profiles': }"
    manifest = '/etc/puppet/manifests/site.pp'
    it 'should work idempotently with no errors' do
      apply_manifest(manifest, :catch_failures => true)
      apply_manifest(manifest, :catch_changes  => true)
    end
    include_examples 'profiles::nrpe'
    include_examples 'profiles::puppet'
    it 'should pass NRPE checks' do
      expect(shell(@nrpe_check_cmd).exit_code).to eq(0)
    end
  end
end
