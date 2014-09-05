require 'spec_helper_acceptance'

describe 'profiles::puppet class' do
  describe service('puppet') do
    it { should be_enabled }
    it { should be_running }
  end
end
