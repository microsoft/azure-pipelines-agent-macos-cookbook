require 'uri'
require 'pry'

module VstsAgentMacOS
  class Agent
    def staff_group
      'staff'
    end

    def pinned_release(version)
      ::URI.encode("https://vstsagentpackage.azureedge.net/agent/#{version}/vsts-agent-osx-x64-#{version}.tar.gz")
    end

    def service_needs_reinstall?
      service_files = ["#{agent_home}/.service", "#{agent_home}/runsvc.sh", launchd_plist]
      service_files.any? { |service_file| !::File.exist? service_file }
    end

    def agent_home
      ::File.join('/Users', admin_user, 'vsts-agent')
    end

    def admin_library
      "#{admin_home}/Library"
    end

    def admin_home
      "/Users/#{admin_user}"
    end

    def account_url
      'https://' + account_name + '.visualstudio.com'
    end

    def vsts_environment
      default_environment.merge(additional_environment)
    end

    def additional_environment
      node['vsts_agent']['additional_environment']
    end

    def default_environment
      { VSTS_AGENT_INPUT_URL: account_url,
        VSTS_AGENT_INPUT_AUTH: 'PAT',
        VSTS_AGENT_INPUT_TOKEN: agent_data[:personal_access_token],
        VSTS_AGENT_INPUT_POOL: node['vsts_agent']['agent_pool'],
        VSTS_AGENT_INPUT_AGENT: new_resource.agent_name,
        HOME: admin_home }
    end

    def target_path
      ::File.join(agent_home, ::File.basename(release_download_url))
    end

    def agent_data
      data_bag_item node['vsts_agent']['data_bag'], node['vsts_agent']['data_bag_item']
    end

    def launchd_plist
      "#{admin_library}/LaunchAgents/#{service_name}.plist"
    end

    def agent_needs_update?
      if ::File.exist?("#{agent_home}/config.sh")
        config_path = ::File.join(agent_home, 'config.sh')
        current_version = shell_out(config_path, '--version', user: admin_user, env: vsts_environment).stdout.chomp
        version_pattern = Regexp.new "\d+\.\d+\.\d+"
        requested_version = release_download_url.match(version_pattern).to_a.last
        ::Gem::Version.new(requested_version) > ::Gem::Version.new(current_version)
      else
        true
      end
    end

    def has_credentials?
      ::File.exist? "#{agent_home}/.credentials"
    end

    def service_name
      Chef.node['vsts_agent']['service_name']
    end

    def agent_name
      Chef.node['vsts_agent']['agent_name']
    end

    def account_name
      Chef.node['vsts_agent']['account']
    end

    def admin_user
      Chef.node['vsts_agent']['admin_user']
    end

    def release_download_url(version = nil)
      version ||= Chef.node['vsts_agent']['version']
      pinned_release(version)
    end
  end
end

Chef::Resource.include(VstsAgent::VstsHelpers)
Chef::Recipe.include(VstsAgent::VstsHelpers)
