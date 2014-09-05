require 'spec_helper_acceptance'

describe 'profiles::nginx class' do
  describe service('nginx') do
    it { should be_enabled }
    it { should be_running }
  end
  describe port(80) do
    it { should be_listening }
  end
end
