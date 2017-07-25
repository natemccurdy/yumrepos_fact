[![Puppet Forge](https://img.shields.io/puppetforge/v/nate/yumrepos_fact.svg)](https://forge.puppetlabs.com/nate/yumrepos_fact)

# Yumrepo Fact

This module adds a custom Facter fact that shows the number of enabled and/or disabled yum repositories on RedHat-like servers.

```shell
[root@centos7 ~]# facter -p yumrepos
{
  enabled => [
    "base",
    "updates",
    "dev_apps",
    "puppet_enterprise"
  ],
  disabled => [
    "base-source",
    "updates-source",
    "extras",
    "extras-source",
    "fasttrack"
  ],
  count => {
    enabled => 4,
    disabled => 5,
    total => 9
  }
}
```

## Example Usage

```puppet
$number_of_repos = $facts['yumrepos']['count']['total']

file { '/etc/motd':
  ensure  => file,
  content => "This node has ${number_of_repos} yum repos on it."
}
```

```puppet
if 'corportate-repo' in $facts['yumrepos']['enabled'] {
  package { 'foo': ensure => present }
} else {
  package { 'bar': ensure => present }
}
```

## Reference

The output of the fact is a hash that contains the following keys:

* `enabled`: An array of the names of enabled repos.
* `disabled`: An array of the names of disabled repos.
* `count`: A hash that contains the following sub keys:
  * `enabled`: Integer - number of enabled repos.
  * `disabled`: Integer - number of disabled repos.
  * `total`: Integer - total number of repos.

## How it works

This fact uses Puppet's resource abstraction layer to list all of local [yumrepo](https://docs.puppet.com/puppet/latest/types/yumrepo.html) resource types on a Puppet agent, as such, Puppet is required for this fact to work. Effectively, this fact is doing a `puppet resource yumrepo` and looking at the `enabled` attribute to determine if a repo is enabled or not.

The name of each yum repo is coming from the title of the relevant `yumrepo` resource type.

Another way to view yum repos is with the command, `yum repolist`; however, I chose not to use that because that would mean shelling out to a system command rather than staying in Ruby land. I haven't done any benchmarking, but I'm guessing it's faster this way.

