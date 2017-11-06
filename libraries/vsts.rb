module VstsAgent
  module VstsHelpers
    def service_started?
      output = shell_out("launchctl list | grep vsts | awk '{print $1}'").stdout
      output =~ /\d+/
    end

    def vsts_environment
      default_environment.merge(additional_environment)
    end

    def default_environment
      agent_data = data_bag_item('vsts', 'build_agent')
      { VSTS_AGENT_INPUT_URL: agent_data[:account_url],
        VSTS_AGENT_INPUT_AUTH: 'PAT',
        VSTS_AGENT_INPUT_TOKEN: agent_data[:personal_access_token],
        VSTS_AGENT_INPUT_POOL: agent_data[:agent_pool_name],
        VSTS_AGENT_INPUT_AGENT: node['vsts_agent']['agent_name'] }
    end

    def additional_environment
      node.default['vsts_agent']['additional_environment'] = {}
    end

    def on_high_sierra_or_newer?
      ::Gem::Version.new(node['platform_version']) > ::Gem::Version.new('10.12.6')
    end

    def agent_home
      node['vsts_agent']['agent_home']
    end

    def admin_home
      "/Users/#{node['vsts_agent']['admin_user']}"
    end

    def already_configured?
      ::File.exist? "#{agent_home}/.credentials"
    end

    def launchd_plist_exists?
      account = node['vsts_agent']['account']
      agent_name = node['vsts_agent']['agent_name']
      ::File.exist? "#{admin_home}/Library/LaunchAgents/vsts.agent.#{account}.#{agent_name}.plist"
    end
  end
end

Chef::Resource.include(VstsAgent::VstsHelpers)
Chef::Recipe.include(VstsAgent::VstsHelpers)
