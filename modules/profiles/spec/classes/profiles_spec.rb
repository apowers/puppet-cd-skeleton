require 'spec_helper'

describe 'profiles' do
  context "class without a role" do
    let(:params) {{ }}
    let(:facts) {{ }}

    it { should compile.with_all_deps }
    it { should contain_class('profiles') }
    it { should contain_class('profiles::apt') }
    it { should contain_class('profiles::nrpe') }
    it { should contain_class('profiles::puppet') }
  end
end
