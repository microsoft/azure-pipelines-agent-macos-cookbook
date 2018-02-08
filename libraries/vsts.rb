require 'uri'

module VstsAgent
  module VstsHelpers
    def release_download_url(version = nil)
      version ||= Chef.node['vsts_agent']['version']
      pinned_release(version)
    end

    def on_high_sierra_or_newer?
      ::Gem::Version.new(Chef.node['platform_version']) > ::Gem::Version.new('10.12.6')
    end

    def service_started?
      output = shell_out(launchctl_command, 'list', user: admin_user).stdout
      vsts_match = output.match(/(?<pid>\d+)\s+.*vsts/)
      process_id?(vsts_match[:pid]) if vsts_match
    end

    def service_needs_reinstall?
      ["#{agent_home}/.service", "#{agent_home}/runsvc.sh", launchd_plist].any? { |service_file| !::File.exist?(service_file) }
    end

    def process_id?(output)
      output.match?(/^\d+$/i)
    end

    def launchctl_command
      '/bin/launchctl'
    end

    def pinned_release(version)
      ::URI.encode("https://vstsagentpackage.azureedge.net/agent/#{version}/vsts-agent-osx-x64-#{version}.tar.gz")
    end
  end
end

Chef::Resource.include(VstsAgent::VstsHelpers)
Chef::Recipe.include(VstsAgent::VstsHelpers)
