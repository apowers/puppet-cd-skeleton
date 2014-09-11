require 'spec_helper_acceptance'

# Include class behavior tests for roles
Dir["./spec/classes/**/*.rb"].sort.each {|f| require f}

describe 'puppet apply' do
  context 'with no role' do
    let(:facts) {{ :role => 'none' }}
    manifest = "class { 'profiles': }"
    it 'should work idempotently with no errors' do
      apply_manifest(manifest, :catch_failures => true)
      apply_manifest(manifest, :catch_changes  => true)
    end
    it_behaves_like 'profiles::nrpe'
    it_behaves_like 'profiles::puppet'
    it 'should pass NRPE checks' do
      expect(shell(@nrpe_check_cmd).exit_code).to eq(0)
    end
  end
end
