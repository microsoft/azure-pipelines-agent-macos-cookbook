# VSTS Agent Cookbook for macOS

## Attributes

### Agent Name
The name of the agent.

**Default value:** `node['hostname']`

```ruby
default['vsts_agent']['agent_name']
```

### Agent Version
The version of the agent to install.

**Default value:** `'latest'`

```ruby
default['vsts_agent']['version']
```

### VSTS Account Name
The name of your VSTS account. You **must** set this attribute if you are not a member of the "Office" account.

**Default value:** `'office'`
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

**Default value:** `'/Users/node['vsts_agent']['admin_user']/vsts-agent'`
```ruby
default['vsts_agent']['agent_home']
```

### Additional Environment Variables
An optional hash may be set to pass environment variables to the agent. The agent will then
be configured with these environment variables which it will then report back to
the server.

**Default value:** `{}`
```ruby
default['vsts_agent']['additional_environment']
```

## Required Data Bag

For now, you'll need to create a data bag called 'vsts' with a bag item called 'build_agent' that contains three keys:
- `personal_access_token`
- `agent_pool_name`
- `account_url`

The three keys will be used to configure the agent.
