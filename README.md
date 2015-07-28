Augeas_file resource type
=========================

[![Puppet Forge Version](http://img.shields.io/puppetforge/v/camptocamp/augeas_file.svg)](https://forge.puppetlabs.com/camptocamp/augeas_file)
[![Puppet Forge Downloads](http://img.shields.io/puppetforge/dt/camptocamp/augeas_file.svg)](https://forge.puppetlabs.com/camptocamp/augeas_file)
[![Build Status](https://img.shields.io/travis/camptocamp/puppet-augeas_file/master.svg)](https://travis-ci.org/camptocamp/puppet-augeas_file)


# Requirements

- [Augeas](http://augeas.net) >= 1.0.0
- ruby-augeas >= 0.5.0

# Usage

```puppet
file { '/etc/apt/sources.list.d/jessie.list':
  ensure => file,
  owner  => 'root',
  group  => 'root',
} ->
augeas_file { '/etc/apt/sources.list.d/jessie.list':
  lens    => 'Aptsources.lns',
  base    => '/usr/share/doc/apt/examples/sources.list',
  changes => ['setm ./*[distribution] distribution jessie'],
}
```

```puppet
file { '/var/www/blog/conf/userdir.conf':
  ensure => file,
  owner  => 'www-data',
  group  => 'root',
} ->
augeas_file { '/var/www/blog/conf/userdir.conf':
  base    => '/usr/share/doc/apache2.2-common/examples/apache2/extra/httpd-userdir.conf',
  lens    => 'Httpd.lns',
  changes => [
    'set Directory/arg "\"/var/www/blog/htdocs\""',
    'rm Directory/directive/arg[.="Indexes"]',
  ],
}
```
