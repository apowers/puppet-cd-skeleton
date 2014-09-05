require 'spec_helper_acceptance'

describe 'profiles class' do
  context 'default parameters' do
    # Using puppet_apply as a helper
    it 'should work idempotently with no errors' do
      pp = <<-EOS
      class { 'profiles::nrpe': }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes  => true)
    end

    describe service('nagios-nrpe-server') do
      it { should be_enabled }
      it { should be_running }
    end

    describe port(5666) do
      it { should be_listening }
    end

  end
end
