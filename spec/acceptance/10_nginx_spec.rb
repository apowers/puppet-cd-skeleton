# Shared examples for Nginx server
shared_examples 'profiles::nginx' do
  describe 'includes profiles::nginx with' do
    describe service('nginx') do
      it { should be_enabled }
      it { should be_running }
    end
    describe port(80) do
      it { should be_listening }
    end
  end
end
