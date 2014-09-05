require 'spec_helper'

describe 'profiles::jenkins' do
  context "class with profile jenkins" do
    let(:params) {{ }}
    let(:facts) {{ }}

    it { should compile.with_all_deps }
    it { should contain_class('profiles::jenkins') }
    it { should contain_class('nginx') }
    it { should contain_class('jenkins') }
  end
end
