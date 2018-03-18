ruby_block 'service is up and running' do
  block do
    cmd = shell_out '/bin/launchctl', 'list', user: Agent.admin_user
    agents = cmd.stdout.lines.map { |line| line.split("\t").last.strip }
    raise Chef::Application.fatal!('VSTS agent service is not enabled!') unless agents.include? Agent.service_name
  end
end
