require 'spec_helper'

describe 'profiles::puppet' do
  context "class with profile puppet" do
    let(:params) {{ }}
    let(:facts) {{ }}

    it { should compile.with_all_deps }
    it { should contain_class('profiles::puppet') }
    it { should contain_class('puppet') }
  end
end
