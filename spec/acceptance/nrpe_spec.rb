require 'spec_helper_acceptance'

describe 'profiles::nginx class' do
  describe service('nagios-nrpe-server') do
    it { should be_enabled }
    it { should be_running }
  end

  describe port(5666) do
    it { should be_listening }
  end
end
