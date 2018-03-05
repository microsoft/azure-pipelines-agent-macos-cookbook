name 'vsts_agent_macos'
maintainer 'Eric Hanko'
maintainer_email 'eric.hanko1@gmail.com'
license 'MIT'
description 'A dedicated cookbook for configuring a VSTS build/release agent on macOS.'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '1.1.1'
chef_version '~> 13.0' if respond_to?(:chef_version)

depends 'homebrew'
depends 'tar'
depends 'macos'
depends 'sudo'
