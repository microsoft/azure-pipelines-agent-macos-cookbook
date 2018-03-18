module VstsAgentMacOS
  class LaunchdService
    def initialize(service_label)
      @label = service_label
      @enabled = false
      @running = false
    end

    def service_needs_reinstall?
      service_files = ["#{agent_home}/.service", "#{agent_home}/runsvc.sh", Agent.launchd_plist]
      service_files.any? { |service_file| !::File.exist? service_file }
    end

    def enabled?
      running_processes.any? { |process| process[:service_name] == Agent.service_name }
    end

    def process_id?(output)
      output.match?(/^\d+$/i)
    end

    def process_map(command_output = nil)
      command_output ||= launchctl_list_output
      capture_pattern = /(?<pid>[\-\d]+)\t(?<exit_code>[\-\d]+)\t(?<service_name>.+)/
      processes = command_output.lines
      processes.map { |process| process.match(capture_pattern).named_captures }
    end

    private

    def launchctl_command
      '/bin/launchctl'
    end

    def launchctl_list_command
      shell_out launchctl_command, 'list', @label, user: Agent.admin_user
    end
  end
end
