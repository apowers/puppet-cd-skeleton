# site.pp
# Include Hiera Classes
hiera_include('classes')

# Resource Defaults
# http://docs.puppetlabs.com/references/latest/type.html

# File Resounce Defaults
File {
    owner       => '0',
    group       => '0',
    mode        => '640',
    backup      => 'puppet',
    checksum    => 'md5',
    ignore      => '\.\w*',
    recurse     => false,
    purge       => false,
    replace     => true,
}

Exec {
  path => ['/bin','/sbin','/usr/bin','/usr/sbin'],
}

#Docker used a different init system
if $::virtual == 'docker' {
  Service { provider => 'init' }
}
