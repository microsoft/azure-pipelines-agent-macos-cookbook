name 'azure_pipelines_agent_macos'
maintainer 'Microsoft'
maintainer_email 'chef@microsoft.com'
license 'MIT'
description 'A dedicated cookbook for configuring an Azure DevOps build or release agent on macOS.'
chef_version '>= 14.0'
version '3.1.0'

supports 'mac_os_x'

source_url 'https://github.com/microsoft/azure-pipelines-agent-macos-cookbook'
issues_url 'https://github.com/microsoft/azure-pipelines-agent-macos-cookbook/issues'

depends 'homebrew', '~> 5.0.0'
depends 'tar', '~> 2.0.0'
