include_recipe 'vsts_agent_macos::bootstrap'

log '================================================== WARNING! =================================================='
log '================================================== WARNING! =================================================='
log "\'#{cookbook_name}::#{recipe_name}\' has been renamed to \'#{cookbook_name}::bootstrap\' and will be removed in a later release."
log "Update any cookbooks that use \'#{cookbook_name}::#{recipe_name}\' and replace with \'#{cookbook_name}::bootstrap\'"
log '================================================== WARNING! =================================================='
log '================================================== WARNING! =================================================='
