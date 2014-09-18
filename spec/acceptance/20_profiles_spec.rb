require 'spec_helper_acceptance'

describe 'puppet apply' do
  context 'with role=none' do
    let(:facts) {{ :role => 'none' }}
    include_context 'initializer'

    it 'should work idempotently with no errors' do
      apply_manifest(manifest, :catch_failures => true)
      apply_manifest(manifest, :catch_changes  => true)
    end

    include_examples 'profiles::nrpe'
    include_examples 'profiles::puppet'

    it 'should pass NRPE checks' do
      expect( shell(@nrpe_check_cmd).exit_code ).to eq(0)
    end

  end
end
