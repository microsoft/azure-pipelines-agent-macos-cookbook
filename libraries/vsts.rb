include Chef::Mixin::ShellOut

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
      %w(.credentials config.sh).all? { |file| ::File.exist? "#{agent_home}/#{file}" }
    end

    def launchd_plist_exists?
      account = node['vsts_agent']['account']
      agent_name = node['vsts_agent']['agent_name']
      ::File.exist? "#{admin_home}/Library/LaunchAgents/vsts.agent.#{account}.#{agent_name}.plist"
    end

    def release_download_url
      version = node['vsts_agent']['version']
      if version == 'latest'
        latest_release
      else
        pinned_release(version)
      end
    end

    def agent_needs_update?
      current_version = already_configured? ? shell_out("#{agent_home}/config.sh --version").stdout : '0'
      requested_version = release_download_url.match(%r{\/v(\d+\.\d+\.\d+)\/}).to_a.last
      requested_version > current_version
    end

    private

    def latest_release
      require 'json'
      require 'net/http'
      require 'uri'

      uri = URI.parse('https://api.github.com/repos/Microsoft/vsts-agent/releases/latest')
      response = Net::HTTP.get_response(uri)
      body = JSON.parse(response.body)
      body['assets'].select { |link| link['name'] =~ /osx/ }.first['browser_download_url']
    end

    def pinned_release(version)
      "https://github.com/Microsoft/vsts-agent/releases/download/v#{version}/vsts-agent-osx.10.11-x64-#{version}.tar.gz"
    end
  end
end

Chef::Resource.include(VstsAgent::VstsHelpers)
Chef::Recipe.include(VstsAgent::VstsHelpers)
