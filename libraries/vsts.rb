require 'json'
require 'net/http'
require 'uri'

include Chef::Mixin::ShellOut

module VstsAgent
  module VstsHelpers
    def on_high_sierra_or_newer?
      ::Gem::Version.new(Chef.node['platform_version']) > ::Gem::Version.new('10.12.6')
    end

    def azure_release?
      ::Gem::Version.new(Chef.node['vsts_agent']['version']) >= ::Gem::Version.new('2.126.0')
    end

    def release_download_url(version = nil)
      version ||= Chef.node['vsts_agent']['version']
      version == 'latest' ? latest_release : compatible_pinned_version(version)
    end

    def latest_release
      on_high_sierra_or_newer? ? pinned_azure_release('2.129.0') : pinned_release('2.125.1')
    end

    def compatible_pinned_version(version)
      if azure_release? && on_high_sierra_or_newer?
        pinned_azure_release(version)
      elsif azure_release? && !on_high_sierra_or_newer?
        raise Chef::Application.fatal!("Whoops! macOS #{node['platform_version']} does not support VSTS agent v#{version}.", 1)
      else
        pinned_release(version)
      end
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
      "https://github.com/Microsoft/vsts-agent/releases/download/v#{version}/vsts-agent-osx.10.11-x64-#{version}.tar.gz"
    end

    def pinned_azure_release(version)
      "https://vstsagentpackage.azureedge.net/agent/#{version}/vsts-agent-osx-x64-#{version}.tar.gz"
    end

    def latest_release_response_body
      uri = ::URI.parse('https://api.github.com/repos/Microsoft/vsts-agent/releases/latest')
      response = ::Net::HTTP.get_response(uri)
      response.body
    end
  end
end

Chef::Resource.include(VstsAgent::VstsHelpers)
Chef::Recipe.include(VstsAgent::VstsHelpers)
