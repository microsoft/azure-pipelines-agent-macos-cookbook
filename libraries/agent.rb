require 'cgi/util'

include Chef::Mixin::ShellOut

module AzurePipelines
  class Agent
    class << self
      def release_download_url(version = nil)
        version ||= agent_attrs['version']
        ::CGI::Util.escapeHTML("https://vstsagentpackage.azureedge.net/agent/#{version}/vsts-agent-osx-x64-#{version}.tar.gz")
      end

      def agent_home
        ::File.join admin_home, 'azure-pipelines-agent'
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

      def environment
        default_environment.merge additional_environment
      end

      def additional_environment
        agent_attrs['additional_environment']
      end

      def default_environment
        account_url = ::File.join 'https://dev.azure.com', agent_attrs['account']
        {
          HOME: admin_home,
          VSTS_AGENT_INPUT_AGENT: agent_attrs['agent_name'],
          VSTS_AGENT_INPUT_DEPLOYMENTGROUPNAME: agent_attrs['deployment_group'],
          VSTS_AGENT_INPUT_DEPLOYMENTGROUPTAGS: agent_attrs['deployment_group_tags'],
          VSTS_AGENT_INPUT_POOL: agent_attrs['agent_pool'],
          VSTS_AGENT_INPUT_PROJECTNAME: agent_attrs['project'],
          VSTS_AGENT_INPUT_URL: account_url,
          VSTS_AGENT_INPUT_WORK: agent_attrs['work'],
        }
      end

      def launchd_plist
        ::File.join '/', 'Library', 'LaunchAgents', "#{service_name}.plist"
      end

      def needs_update?
        config_script = ::File.join agent_home, 'config.sh'
        if ::File.exist? config_script
          version_command = shell_out config_script, '--version', user: admin_user, env: environment
          current_version = version_command.stdout.chomp
          requested_version = agent_attrs['version']
          ::Gem::Version.new(requested_version) > ::Gem::Version.new(current_version)
        else
          true
        end
      end

      def configuration_type
        agent_attrs['deployment_group'].nil? ? '' : '--deploymentgroup'
      end

      def user_group
        agent_attrs['user_group']
      end

      def credentials?
        credentials = ::File.join agent_home, '.credentials'
        ::File.exist? credentials
      end

      def service_name
        agent_attrs['service_name']
      end

      def agent_name
        agent_attrs['agent_name']
      end

      def admin_user
        agent_attrs['admin_user']
      end

      def agent_attrs
        Chef.node['azure_pipelines_agent']
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

Chef::Resource.include AzurePipelines
Chef::Recipe.include AzurePipelines
