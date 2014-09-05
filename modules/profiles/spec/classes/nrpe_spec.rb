require 'spec_helper'

describe 'profiles::nrpe' do
  context "class with profile nrpe" do
    let(:params) {{ }}
    let(:facts) {{ }}

    it { should compile.with_all_deps }
    it { should contain_class('profiles::nrpe') }
    it { should contain_class('nrpe') }
  end
end
