# require 'spec_helper_acceptance'

shared_examples 'profiles::jenkins' do
  describe 'includes profiles::jenkins with' do
    describe service('jenkins') do
      it { should be_enabled }
      it { should be_running }
    end
    describe port(8080) do
      it { should be_listening }
    end
  end
end
