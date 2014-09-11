require 'spec_helper_acceptance'

# Include class behavior tests for roles
Dir["./spec/classes/**/*.rb"].sort.each {|f| require f}

describe 'puppet apply' do
  context 'with role cd_demo' do
#    let(:facts) {{ :role => 'cd_demo' }}
#    ENV['facter_role']='cd_demo'
    it 'should work idempotently with no errors' do
      expect(shell('facter_role=cd_demo puppet apply /etc/puppet/manifests/site.pp').exit_code).to_not eq(1)
      expect(shell('facter_role=cd_demo puppet apply /etc/puppet/manifests/site.pp').exit_code).to eq(0)
    end
    it_behaves_like 'profiles::nginx'
    it_behaves_like 'profiles::jenkins'
    it 'should pass NRPE checks' do
      shell('puppet apply /etc/puppet/manifests/site.pp')
      expect( shell(@nrpe_check_cmd).exit_code ).to eq(0)
    end
  end
end
