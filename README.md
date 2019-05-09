Azure DevOps Build and Release Agent Cookbook for macOS
=======================================================

[![Build status](https://dev.azure.com/office/APEX/_apis/build/status/Apple%20Lab/cookbooks/azure_pipelines_agent_macos)](https://dev.azure.com/office/APEX/_build/latest?definitionId=2373)

[Visual Studio Team Services is now Azure DevOps Services](https://docs.microsoft.com/en-us/azure/devops/user-guide/what-happened-vsts)
We're working on the best way to rename the cookbook and recipes while maintaining backwards compatibility.

Recipes
-------

### Bootstrap

Usage: `azure_piplines_agent_macos::bootstrap`

Add the node to the agent pool or deployment group.

### Teardown

Usage: `azure_piplines_agent_macos::teardown`

Remove an existing agent from the build pool or deployment group.

Attributes
----------

### Agent Name

The name of the agent.

**Default value:** `node['hostname']`

```ruby
default['azure_piplines_agent']['agent_name']
```

### Agent Version

The version of the agent to install.

**Default value:** `'2.150.3'`

```ruby
default['azure_piplines_agent']['version']
```

### Agent Pool

The name of the agent pool you wish to add the agent to.

**Default value:** `American Hanko's Agents`

```ruby
default['azure_piplines_agent']['agent_pool']
```

### Organization Name

The name of your Azure DevOps organization. (e.g. 'americanhanko' in `https://dev.azure.com/americanhanko`)

**Default value:** `americanhanko`

```ruby
default['azure_piplines_agent']['account']
```

### Admin User

The username of an adminstrator on the macOS system.

**Default value:** `'vagrant'`

```ruby
default['azure_piplines_agent']['admin_user']
```

### Agent Home Directory

The location that contains all builds, source, release, etc.

**Default value:** `'/Users/#{node['azure_piplines_agent']['admin_user']}/azure-piplines-agent'`

```ruby
default['azure_piplines_agent']['agent_home']
```

### Additional Environment Variables

An optional hash may be set to pass environment variables to the agent. The agent
will then be configured with these environment variables which it will then
report back to the servers.

**Default value:** `{}`

```ruby
default['azure_piplines_agent']['additional_environment']
```

Deployment Group
----------------

This cookbook supports adding agents to Azure DevOps deployment groups. To use this feature, simply
set the `default['azure_piplines_agent']['deployment_group']` attribute. In addition, make sure you have
the appropriate values set for the following attributes shown below. By default, we assume that
if the `default['azure_piplines_agent']['deployment_group']` attribute is `nil`, we are bootstrapping
a build agent and _not_ a deployment agent. This means if you set this attribute, it will
override the default functionality. You may optionally specifiy deployment group tags using
`default['azure_piplines_agent']['deployment_group_tags']`.

```ruby
default['azure_piplines_agent']['deployment_group'] = nil
default['azure_piplines_agent']['project'] = nil
default['azure_piplines_agent']['work'] = nil
default['azure_piplines_agent']['deployment_group_tags'] = nil
```

Authentication
--------------

This cookbook uses a [personal access token](https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate)
to authenticate to your organization on the Azure DevOps servers. The cookbook allows access to the token via either an attribute, within a data bag or using a chef vault item.

### Plaintext Attribute

Example:

```ruby
default['azure_piplines_agent']['pat'] = '0fbdebc988934add98179ddaae019a01711'
```

### Data Bag or Chef Vault Item

Name your vault or bag and corresponding item whatever you like and
make sure to set the corresponding attributes to reference it
accordingly:

Example:

```ruby
default['azure_piplines_agent']['data_bag'] = 'tea_bag'
default['azure_piplines_agent']['data_bag_item'] = 'green_tea'
```

However, it **must** contain a `personal_access_token` key with
the token itself as the value. The token must have rights to read and modify
build agents. The permissions are selected at the time of the PAT creation, which
you can read more about [here](https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate).

Example:

```json
{
  "id": "azure_piplines_build_agent",
  "personal_access_token": "iu8tfaxxrhce7yeu434yo9zfjtxif3jygzk24wegi855er2moobs"
}
```
