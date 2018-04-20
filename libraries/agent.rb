require 'uri'

include Chef::Mixin::ShellOut

module VstsAgentMacOS
  class Agent
    class << self
      def release_download_url(version = nil)
        version ||= Chef.node['vsts_agent']['version']
        ::URI.encode("https://vstsagentpackage.azureedge.net/agent/#{version}/vsts-agent-osx-x64-#{version}.tar.gz")
      end

      def agent_home
        ::File.join admin_home, 'vsts-agent'
      end

      def admin_library
        ::File.join admin_home, 'Library'
      end

      def service_log_path
        ::File.join admin_library, 'Logs', service_name
      end

      def admin_home
        ::File.join '/', 'Users', admin_user
      end

      def account_url
        'https://' + account_name + '.visualstudio.com'
      end

      def vsts_environment
        default_environment.merge(additional_environment)
      end

      def additional_environment
        Chef.node['vsts_agent']['additional_environment']
      end

      def default_environment
        { VSTS_AGENT_INPUT_URL: account_url,
          VSTS_AGENT_INPUT_AUTH: 'PAT',
          VSTS_AGENT_INPUT_TOKEN: agent_data[:personal_access_token],
          VSTS_AGENT_INPUT_POOL: Chef.node['vsts_agent']['agent_pool'],
          VSTS_AGENT_INPUT_AGENT: Chef.node['vsts_agent']['agent_name'],
          HOME: admin_home }
      end

      def agent_data
        vsts_data = Chef.node['vsts_agent']
        Chef::DataBagItem.load(vsts_data['data_bag'], vsts_data['data_bag_item'])
      end

      def launchd_plist
        ::File.join('/', 'Library', 'LaunchAgents', "#{service_name}.plist")
      end

      def needs_update?
        config_script = ::File.join agent_home, 'config.sh'
        if ::File.exist? config_script
          version_command = shell_out(config_script, '--version', user: admin_user, env: vsts_environment)
          current_version = version_command.stdout.chomp
          requested_version = Chef.node['vsts_agent']['version']
          ::Gem::Version.new(requested_version) > ::Gem::Version.new(current_version)
        else
          true
        end
      end

      def user_group
        Chef.node['vsts_agent']['user_group']
      end

      def credentials?
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
    end
  end
end

Chef::Resource.include(VstsAgentMacOS)
Chef::Recipe.include(VstsAgentMacOS)
