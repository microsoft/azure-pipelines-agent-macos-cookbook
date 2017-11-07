include Chef::Mixin::ShellOut

module VstsAgent
  module VstsHelpers
    require 'json'
    require 'net/http'
    require 'uri'

    def admin_user
      node['vsts_agent']['admin_user']
    end

    def agent_home
      node['vsts_agent']['agent_home']
    end

    def agent_name
      node['vsts_agent']['agent_name']
    end

    def admin_library
      "#{admin_home}/Library"
    end

    def admin_home
      "/Users/#{admin_user}"
    end

    def vsts_environment
      default_environment.merge(additional_environment)
    end

    def on_high_sierra_or_newer?
      ::Gem::Version.new(node['platform_version']) > ::Gem::Version.new('10.12.6')
    end

    def needs_configuration?
      !::File.exist? "#{agent_home}/.credentials"
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
      current_version = shell_out!("sudo -u #{admin_user} #{agent_home}/config.sh --version").stdout
      requested_version = release_download_url.match(%r{\/v(\d+\.\d+\.\d+)\/}).to_a.last
      ::Gem::Version.new(requested_version) > ::Gem::Version.new(current_version)
    end

    def service_started?
      output = shell_out!("sudo -u #{admin_user} launchctl list | grep vsts | awk '{print $1}'").stdout.chomp
      process_id?(output)
    end

    def service_needs_reinstall?
      ["#{agent_home}/.service", "#{agent_home}/runsvc.sh", launchd_plist].any? { |service_file| !::File.exist?(service_file) }
    end

    def process_id?(output)
      !!(output =~ /^\d+$/i)
    end

    def launchd_plist
      "#{admin_library}/LaunchAgents/vsts.agent.office.#{agent_name}.plist"
    end

    def additional_environment
      node['vsts_agent']['additional_environment']
    end

    def default_environment
      agent_data = data_bag_item('vsts', 'build_agent')
      { VSTS_AGENT_INPUT_URL: agent_data[:account_url],
        VSTS_AGENT_INPUT_AUTH: 'PAT',
        VSTS_AGENT_INPUT_TOKEN: agent_data[:personal_access_token],
        VSTS_AGENT_INPUT_POOL: agent_data[:agent_pool_name],
        VSTS_AGENT_INPUT_AGENT: node['vsts_agent']['agent_name'],
        HOME: admin_home }
    end

    def latest_release
      uri = ::URI.parse('https://api.github.com/repos/Microsoft/vsts-agent/releases/latest')
      response = ::Net::HTTP.get_response(uri)
      body = ::JSON.parse(response.body)
      body['assets'].select { |asset| asset['name'] =~ /osx/ }.first['browser_download_url']
    end

    def pinned_release(version)
      "https://github.com/Microsoft/vsts-agent/releases/download/v#{version}/vsts-agent-osx.10.11-x64-#{version}.tar.gz"
    end
  end
end

Chef::Resource.include(VstsAgent::VstsHelpers)
Chef::Recipe.include(VstsAgent::VstsHelpers)
