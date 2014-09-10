require 'spec_helper_acceptance'

shared_context 'with role'  do
  before do
    puppet_apply('/etc/puppet/manifests/site.pp')
  end
end
