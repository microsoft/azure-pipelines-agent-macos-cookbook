require 'json'
require 'net/http'
require 'uri'

include Chef::Mixin::ShellOut

module VstsAgent
  module VstsHelpers
    def on_high_sierra_or_newer?
      ::Gem::Version.new(Chef.node['platform_version']) > ::Gem::Version.new('10.12.6')
    end

    def release_download_url(version = nil)
      version ||= Chef.node['vsts_agent']['version']
      if version == 'latest'
        latest_release
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

    def latest_release(response_body = nil)
      response_body ||= latest_release_response_body
      body = ::JSON.parse(response_body)
      assets = body['assets']
      if assets.empty?
        'https://vstsagentpackage.azureedge.net/agent/2.126.0/vsts-agent-osx-x64-2.126.0.tar.gz'
      else
        assets.select { |asset| asset['name'] =~ /osx/ }.first['browser_download_url']
      end
    end

    def launchctl_command
      '/bin/launchctl'
    end

    def pinned_release(version)
      "https://github.com/Microsoft/vsts-agent/releases/download/v#{version}/vsts-agent-osx.10.11-x64-#{version}.tar.gz"
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
