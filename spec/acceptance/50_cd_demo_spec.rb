require 'spec_helper_acceptance'

describe 'puppet apply' do
  context 'with role=cd_demo' do
    let(:facts) {{ :role => 'cd_demo' }}
    include_context 'initializer'

    it 'should work idempotently with no errors' do
#      apply_manifest(manifest, :catch_failures => true)
      expect(shell("facter_role=cd_demo #{puppet_apply_cmd}").exit_code).to_not eq(1)

#      apply_manifest(manifest, :catch_changes  => true)
      expect(shell("facter_role=cd_demo #{puppet_apply_cmd}").exit_code).to eq(0)
    end

    include_examples 'profiles::nginx'
    include_examples 'profiles::jenkins'

    it 'should pass NRPE checks' do
      expect( shell(@nrpe_check_cmd).exit_code ).to eq(0)
    end

  end
end
