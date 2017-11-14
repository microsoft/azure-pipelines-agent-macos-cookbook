require 'json'
require 'net/http'
require 'uri'

include Chef::Mixin::ShellOut

module VstsAgent
  module VstsHelpers
    def on_high_sierra_or_newer?
      ::Gem::Version.new(node['platform_version']) > ::Gem::Version.new('10.12.6')
    end

    def release_download_url
      version = node['vsts_agent']['version']
      if version == 'latest'
        latest_release
      else
        pinned_release(version)
      end
    end

    def service_started?
      output = shell_out('su', '-l', admin_user, '-c', 'launchctl list').stdout
      vsts_match = output.match(/(?<pid>\d+)\s+.*vsts/)
      process_id?(vsts_match[:pid]) if vsts_match
    end

    def service_needs_reinstall?
      ["#{agent_home}/.service", "#{agent_home}/runsvc.sh", launchd_plist].any? { |service_file| !::File.exist?(service_file) }
    end

    def process_id?(output)
      output.match?(/^\d+$/i)
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
