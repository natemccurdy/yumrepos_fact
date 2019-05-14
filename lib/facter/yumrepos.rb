require 'puppet'

Facter.add(:yumrepos) do
  confine osfamily: 'RedHat'

  setcode do
    enabled_repos  = []
    disabled_repos = []

    # In YUM, possible values for an enabled repo are 'yes', '1', and 'true'.
    # Additionally, YUM treats a repository without an 'enabled' setting as
    # enabled. In the Puppet catalog, a yumrepo without an 'enabled' attribute
    # shows the attribute as :absent. Everything else is considered disabled.
    Puppet::Resource.indirection.search('yumrepo').each do |repo|
      case repo[:enabled]
      when 'yes', '1', 'true', :absent
        enabled_repos << repo.title
      else
        disabled_repos << repo.title
      end
    end

    repos_info             = {}
    repos_info['enabled']  = enabled_repos
    repos_info['disabled'] = disabled_repos
    repos_info['count']    = {
      'enabled'  => enabled_repos.count,
      'disabled' => disabled_repos.count,
      'total'    => enabled_repos.count + disabled_repos.count,
    }

    repos_info
  end
end
