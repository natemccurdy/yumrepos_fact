require 'spec_helper_acceptance'
require 'json'

# @summary: Helper function to run a fact using the lib dir from our module.
#           Uses Litmus's run_shell() function and returns a Hash containing
#           a 'stdout', 'stderr', and 'exit_code' key.
# @param [string]  fact_name: The name of the fact to evaluate
def run_fact
  run_shell('facter -j -p --custom-dir /etc/puppetlabs/code/environments/production/modules/yumrepos_fact/lib/facter yumrepos').first['result']
end

describe 'yumrepos' do
  context 'when evaluating the fact' do
    it 'exit code should be 0' do
      expect(run_fact['exit_code']).to eq(0)
    end
  end

  context 'when two repos are enabled and one repo is disabled' do
    content = <<~REPO
      [foo]
      name=foo
      baseurl=https://.not.a.real.repo
      enabled=1
      [bar]
      name=bar
      baseurl=https://.not.a.real.repo
      enabled=1
      [baz]
      name=baz
      baseurl=https://.not.a.real.repo
      enabled=0
    REPO
    run_shell('rm -rf /etc/yum.repos.d/*')
    run_shell("echo -e \"#{content}\" > /etc/yum.repos.d/test1.repo")

    it 'count.enabled should be 2' do
      expect(JSON.parse(run_fact['stdout'])['yumrepos']['count']['enabled']).to eq(2)
    end

    it 'count.disabled should be 1' do
      expect(JSON.parse(run_fact['stdout'])['yumrepos']['count']['disabled']).to eq(1)
    end

    it 'count.total should be 3' do
      expect(JSON.parse(run_fact['stdout'])['yumrepos']['count']['total']).to eq(3)
    end

    it 'enabled should be the enabled repos' do
      expect(JSON.parse(run_fact['stdout'])['yumrepos']['enabled']).to eq(['foo', 'bar'])
    end

    it 'disabled should be the disabled repos' do
      expect(JSON.parse(run_fact['stdout'])['yumrepos']['disabled']).to eq(['baz'])
    end
  end
end
