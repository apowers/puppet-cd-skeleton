require 'spec_helper'

describe 'profiles::apt' do
  context "class with profile apt" do
    let(:params) {{ }}
    let(:facts) {{ }}

    it { should compile.with_all_deps }
    it { should contain_class('profiles::apt') }
    it { should contain_class('apt') }
  end
end
