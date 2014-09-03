require 'spec_helper'

describe 'profiles' do
  context 'supported operating systems' do
    ['Debian', 'RedHat'].each do |osfamily|
      describe "profiles class without any parameters on #{osfamily}" do
        let(:params) {{ }}
        let(:facts) {{
          :osfamily => osfamily,
        }}

        it { should compile.with_all_deps }

        it { should contain_class('profiles::params') }
        it { should contain_class('profiles::install').that_comes_before('profiles::config') }
        it { should contain_class('profiles::config') }
        it { should contain_class('profiles::service').that_subscribes_to('profiles::config') }

        it { should contain_service('profiles') }
        it { should contain_package('profiles').with_ensure('present') }
      end
    end
  end

  context 'unsupported operating system' do
    describe 'profiles class without any parameters on Solaris/Nexenta' do
      let(:facts) {{
        :osfamily        => 'Solaris',
        :operatingsystem => 'Nexenta',
      }}

      it { expect { should contain_package('profiles') }.to raise_error(Puppet::Error, /Nexenta not supported/) }
    end
  end
end
