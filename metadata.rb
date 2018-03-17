name 'vsts_agent_macos'
maintainer 'Eric Hanko'
maintainer_email 'eric.hanko1@gmail.com'
license 'MIT'
description 'A dedicated cookbook for configuring a VSTS build/release agent on macOS.'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '1.1.3'
chef_version '~> 13.0' if respond_to?(:chef_version)

source_url 'https://github.com/americanhanko/vsts-agent-macos-cookbook'
issues_url 'https://github.com/americanhanko/vsts-agent-macos-cookbook/issues'

depends 'homebrew', '~> 4.3.0'
depends 'tar', '~> 2.1.0'
depends 'macos', '~> 1.8.0'
depends 'sudo', '~> 5.3.0'
