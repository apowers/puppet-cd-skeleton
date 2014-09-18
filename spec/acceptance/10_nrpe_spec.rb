# Shared examples for NRPE server.
shared_examples 'profiles::nrpe' do
  describe 'includes profiles::nrpe with' do
    describe service('nagios-nrpe-server') do
      it { should be_enabled }
      it { should be_running }
    end

    describe port(5666) do
      it { should be_listening }
    end
  end
end
