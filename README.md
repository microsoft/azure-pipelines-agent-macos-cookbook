VSTS Agent Cookbook for macOS
=============================

Attributes
----------

### Agent Name

The name of the agent.

**Default value:** `node['hostname']`

```ruby
default['vsts_agent']['agent_name']
```

### Agent Version

The version of the agent to install.

**Default value:** `'2.129.0'`

```ruby
default['vsts_agent']['version']
```

### VSTS Agent Pool

The name of the agent pool you wish to add the agent to.

**Default value:** `American Hanko's Agents`

```ruby
default['vsts_agent']['agent_pool']
```

### VSTS Account Name

The name of your VSTS account. (i.e. 'americanhanko' in `https://americanhanko.visualstudio.com`)

**Default value:** `americanhanko`

```ruby
default['vsts_agent']['account']
```

### Admin User

The username of an adminstrator on the macOS system.

**Default value:** `'vagrant'`

```ruby
default['vsts_agent']['admin_user']
```

### VSTS Agent Home directory

The location where containing all of the VSTS builds, sources, etc.

**Default value:** `'/Users/#{node['vsts_agent']['admin_user']}/vsts-agent'`

```ruby
default['vsts_agent']['agent_home']
```

### Additional Environment Variables

An optional hash may be set to pass environment variables to the agent. The agent
will then be configured with these environment variables which it will then
report back to the server.

**Default value:** `{}`

```ruby
default['vsts_agent']['additional_environment']
```

Required Data Bag Item
----------------------

For now, you'll need to create a data bag. Name your bag and corresponding item
whatever you like and make sure to set the corresponding attributes:

```ruby
default['vsts_agent']['data_bag']
default['vsts_agent']['data_bag_item']
```

Additionally, it must contain a `personal_access_token` key with
the token itself as the value. The token must have rights to read and modify
VSTS build agents. The permissions are selected at the time of the PAT creation.

Example:

```json
{
  "id": "vsts_build_agent",
  "personal_access_token": "iu8tfaxxrhce7yeu434yo9zfjtxif3jygzk24wegi855er2moobs",
}
```
