require 'json'
require 'net/http'
require 'uri'

include Chef::Mixin::ShellOut

module VstsAgent
  module VstsHelpers
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
