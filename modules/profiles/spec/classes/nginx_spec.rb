require 'spec_helper'

describe 'profiles::nginx' do
  context "class with profile nginx" do
    let(:params) {{ }}
    let(:facts) {{ }}

    it { should compile.with_all_deps }
    it { should contain_class('profiles::nginx') }
    it { should contain_class('nginx') }
  end
end
