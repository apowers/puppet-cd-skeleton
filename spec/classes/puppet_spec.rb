require 'spec_helper_acceptance'

shared_examples 'profiles::puppet' do
  describe service('puppet') do
    it { should be_enabled }
    it { should be_running }
  end
end
