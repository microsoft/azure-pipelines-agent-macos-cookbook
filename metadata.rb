name 'vsts_agent'
maintainer 'Eric Hanko'
maintainer_email 'v-erhank@microsoft.com'
license 'MIT'
description 'A dedicated cookbook for configuring a VSTS build/release agent on macOS.'
long_description 'Installs/Configures vsts_agent'
version '0.1.0'
chef_version '>= 12.1' if respond_to?(:chef_version)

depends 'homebrew'
depends 'tar'
