Augeas_file resource type
=========================

[![Puppet Forge Version](http://img.shields.io/puppetforge/v/camptocamp/augeas_file.svg)](https://forge.puppetlabs.com/camptocamp/augeas_file)
[![Puppet Forge Downloads](http://img.shields.io/puppetforge/dt/camptocamp/augeas_file.svg)](https://forge.puppetlabs.com/camptocamp/augeas_file)
[![Build Status](https://img.shields.io/travis/camptocamp/puppet-augeas_file/master.svg)](https://travis-ci.org/camptocamp/puppet-augeas_file)


# What is this?

There are two main approaches when managing a file from Puppet:

* Manage the file in parts:
  - native resource (`host`, `mailalias`, [augeasproviders](http://augeasproviders.com) resource types, etc.)
  - `concat` resource
  - `augeas` resource
  - `file_line` resource

* Manage the file in its entirety:
  - `file` resource with content (template, variables)
  - `file` resource with source (using fileserver or local file)
  - native resources with purging


One case that is not possible with these is to:
  - use a local file as a template
  - modify it to create a target file

The `augeas_file` type allows to do that. It typically allows to use
an example configuration file provided by a system package
and tune it to create a configuration file, idempotently.



# Requirements

- [Augeas](http://augeas.net) >= 1.0.0
- ruby-augeas >= 0.5.0

# Usage

## Standalone

You can use `augeas_file` to manage a file entirely with one resource, listing
Augeas changes in the `changes` parameter:

```puppet
# augeas_file doesn't manage file rights
# use the file resource type for that
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

You might want to wrap this in a defined resource type:

```puppet
define apache::userdir (
  $directory,
) {
  file { $title:
    ensure => file,
    owner  => 'www-data',
    group  => 'root',
  } ->
  augeas_file { $title:
    base    => '/usr/share/doc/apache2.2-common/examples/apache2/extra/httpd-userdir.conf',
    lens    => 'Httpd.lns',
    changes => [
      "set Directory/arg '\"${directory}\"'",
      'rm Directory/directive/arg[.="Indexes"]',
    ],
  }
}

apache::userdir { '/var/www/blog/conf/userdir.conf':
  directory => '/var/www/blog/htdocs',
}
```


## Triggering augeas resources

The `augeas_file` has the possibility of working with other `augeas` resources whose `incl` parameter matches their name:


```puppet
augeas_file { '/var/www/blog/conf/userdir.conf':
  base => '/usr/share/doc/apache2.2-common/examples/apache2/extra/httpd-userdir.conf',
}

augeas { 'userdir directory':
  incl    => '/var/www/blog/conf/userdir.conf',
  lens    => 'Httpd.lns',
  changes => 'set Directory/arg "\"/var/www/blog/htdocs\""',
}

augeas { 'userdir no indexes':
  incl    => '/var/www/blog/conf/userdir.conf',
  lens    => 'Httpd.lns',
  changes => 'rm Directory/directive/arg[.="Indexes"]',
}
```

This allows to split the changes into individual resources.
