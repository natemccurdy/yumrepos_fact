[![Puppet Forge](https://img.shields.io/puppetforge/v/nate/yumrepos_fact.svg)](https://forge.puppetlabs.com/nate/yumrepos_fact)
[![Build Status](https://github.com/natemccurdy/yumrepos_fact/actions/workflows/checks.yml/badge.svg)](https://github.com/natemccurdy/yumrepos_fact/actions/workflows/checks.yml)

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

## Inventory and Reporting Examples

The yumrepos fact can be queried out of PuppetDB to do basic inventory or reporting.

```shell
# Show the value of the yumrepos fact on all nodes.
puppet query 'facts[certname, value] { name = "yumrepos" }'
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

This fact uses Puppet's resource abstraction layer to list all the local [yumrepo](https://docs.puppet.com/puppet/latest/types/yumrepo.html) resources on a node. Effectively, this fact is doing a `puppet resource yumrepo` and parsing the `enabled` attribute to determine if a repo is enabled or not.

The name of each yum repo is coming from the title of the relevant `yumrepo` resource type.

Another way to view yum repos is with the command, `yum repolist`. I chose not to use that because that would mean shelling out to a system command rather than staying in Ruby land. I haven't done any benchmarking, but I'm guessing it's faster this way.

## Contributing and Development

Pull requests are always welcomed!

This module uses the [Puppet Development Kit][pdk] and [Litmus][litmus] for validation and acceptance testing. All pull requests must pass the [GitHub Actions checks][ghactions_checks] before they can be merged.

For local development, here's the workflow I use and what I recommend you use as well:
1. Create a feature branch.
2. Make your changes.
3. Update any docs or README's if user-facing things change.
4. Validate syntax and style: `pdk validate`
5. Run local Litmus acceptance tests (**note:** this requies a functioning local Docker installation):

    ```shell
    pdk bundle exec rake 'litmus:provision[docker, centos:7]'
    pdk bundle exec rake 'litmus:install_agent[puppet]'
    pdk bundle exec rake 'litmus:install_module'
    pdk bundle exec rake 'litmus:acceptance:parallel'
    pdk bundle exec rake 'litmus:tear_down'
    ```

6. Push up your branch to your fork and make a Pull Request.


[pdk]: https://www.puppet.com/docs/pdk/2.x/pdk.html
[litmus]: https://github.com/puppetlabs/puppet_litmus
[ghactions_checks]: https://github.com/natemccurdy/yumrepos_fact/actions/workflows/checks.yml

