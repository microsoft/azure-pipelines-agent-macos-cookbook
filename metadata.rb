name 'vsts_agent_macos'
maintainer 'Eric Hanko'
maintainer_email 'eric.hanko1@gmail.com'
license 'MIT'
description 'A dedicated cookbook for configuring a VSTS build/release agent on macOS.'
long_description 'Installs/Configures the VSTS on macOS'
version '0.1.3'
chef_version '>= 12.1' if respond_to?(:chef_version)

depends 'homebrew'
depends 'tar'
depends 'macos'
depends 'sudo'
