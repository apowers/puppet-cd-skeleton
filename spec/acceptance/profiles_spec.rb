require 'spec_helper_acceptance'

describe 'profiles class' do
  context 'with no role' do
    let(:facts) {{ role => 'none' }}
    it 'should work idempotently with no errors' do
      # Run it twice and test for idempotency
      pp = "class { 'profiles': }"
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes  => true)

      # Run it twice and test for idempotency
#      expect(shell(puppet_apply).exit_code).to_not eq(1)
#      expect(shell(puppet_apply).exit_code).to eq(0)
    end
    it 'should pass NRPE checks' do
      expect(shell('/usr/bin/check_nrpe.sh').exit_code).to eq(0)
    end
  end
end
