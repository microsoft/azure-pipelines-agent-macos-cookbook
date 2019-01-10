require 'uri'

include Chef::Mixin::ShellOut

module VstsAgentMacOS
  class Agent
    class << self
      def release_download_url(version = nil)
        version ||= Chef.node['vsts_agent']['version']
        ::URI.encode "https://vstsagentpackage.azureedge.net/agent/#{version}/vsts-agent-osx-x64-#{version}.tar.gz"
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
        default_environment.merge additional_environment
      end

      def additional_environment
        Chef.node['vsts_agent']['additional_environment']
      end

      def default_environment
        { VSTS_AGENT_INPUT_URL: account_url,
          VSTS_AGENT_INPUT_POOL: Chef.node['vsts_agent']['agent_pool'],
          VSTS_AGENT_INPUT_AGENT: Chef.node['vsts_agent']['agent_name'],
          VSTS_AGENT_INPUT_DEPLOYMENTGROUPNAME: Chef.node['vsts_agent']['deployment_group'],
          VSTS_AGENT_INPUT_DEPLOYMENTGROUPTAGS: Chef.node['vsts_agent']['deployment_group_tags'],
          VSTS_AGENT_INPUT_PROJECTNAME: Chef.node['vsts_agent']['project'],
          VSTS_AGENT_INPUT_WORK: Chef.node['vsts_agent']['work'],
          HOME: admin_home }
      end

      def launchd_plist
        ::File.join '/', 'Library', 'LaunchAgents', "#{service_name}.plist"
      end

      def needs_update?
        config_script = ::File.join agent_home, 'config.sh'
        if ::File.exist? config_script
          version_command = shell_out config_script, '--version', user: admin_user, env: vsts_environment
          current_version = version_command.stdout.chomp
          requested_version = Chef.node['vsts_agent']['version']
          ::Gem::Version.new(requested_version) > ::Gem::Version.new(current_version)
        else
          true
        end
      end

      def configuration_type
        Chef.node['vsts_agent']['deployment_group'].nil? ? '' : '--deploymentgroup'
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

      def worker_running?
        require 'sys/proctable'
        Sys::ProcTable.ps.any? do |p|
          next if p.cmdline.nil?
          p.cmdline.match? /Agent\.Worker/
        end
      end
    end
  end
end

Chef::Resource.include(VstsAgentMacOS)
Chef::Recipe.include(VstsAgentMacOS)
