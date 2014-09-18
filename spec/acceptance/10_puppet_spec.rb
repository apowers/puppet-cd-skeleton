# Shared examples for Puppet Agent
shared_examples 'profiles::puppet' do
  describe 'includes profiles::puppet with' do
    describe service('puppet') do
      it { should be_enabled }
      it { should be_running }
    end
  end
end
