require 'puppet'

# Possible values for an enabled repo are 'yes', '1', and 'true'.
# Everything else is considered disabled. However, there is a
# special case where a [repository] entry doesn't include an
# entry for 'enabled'. YUM treats those as enabled repos, and in
# the Puppet catalog, a yumrepo resource without an attribute has
# that attribute marked as ':absent', so we need to look for that.
def to_boolean(value)
  %w[absent yes true 1].include?(value.downcase)
end

Facter.add(:yumrepos) do
  confine osfamily: 'RedHat'

  setcode do
    enabled_repos  = []
    disabled_repos = []

    Puppet::Type.type('yumrepo').instances.find_all do |repo|
      repo_value = repo.retrieve

      # 1. Take the 'enabled' attribute of each repo and convert it to a boolean true or false.
      # 2. Add the repo's name to the enabled or disabled list based on the boolean value.
      enabled_repos  << repo.name if     to_boolean(repo_value[repo.property(:enabled)].to_s.strip)
      disabled_repos << repo.name unless to_boolean(repo_value[repo.property(:enabled)].to_s.strip)
    end

    repos_info             = {}
    repos_info['enabled']  = enabled_repos
    repos_info['disabled'] = disabled_repos
    repos_info['count']    = {
      'enabled'  => enabled_repos.count,
      'disabled' => disabled_repos.count,
      'total'    => enabled_repos.count + disabled_repos.count
    }

    repos_info
  end
end
