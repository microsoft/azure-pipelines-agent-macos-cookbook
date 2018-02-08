require 'spec_helper'
include VstsAgent::VstsHelpers

describe VstsAgent::VstsHelpers, '#process_id?' do
  context 'when given a proper process id' do
    it 'returns true' do
      expect(process_id?('314')).to be true
    end
  end

  context 'when given a dash (-)' do
    it 'returns false' do
      expect(process_id?('-')).to be false
    end
  end

  context 'when given a process id that contains a newline character' do
    it 'returns false' do
      expect(process_id?('314\n')).to be false
    end
  end

  context 'when the url is nil and version is latest' do
    response_body = '{"url":"https://api.github.com/repos/Microsoft/vsts-agent/releases/8674909","assets_url":"https://api.github.com/repos/Microsoft/vsts-agent/releases/8674909/assets","upload_url":"https://uploads.github.com/repos/Microsoft/vsts-agent/releases/8674909/assets{?name,label}","html_url":"https://github.com/Microsoft/vsts-agent/releases/tag/v2.126.0","id":8674909,"tag_name":"v2.126.0","target_commitish":"54fa61b7cbd67e9c769b22fd7b63007e7d4827a1","name":"v2.126.0","draft":false,"author":{"login":"TingluoHuang","id":1750815,"avatar_url":"https://avatars3.githubusercontent.com/u/1750815?v=4","gravatar_id":"","url":"https://api.github.com/users/TingluoHuang","html_url":"https://github.com/TingluoHuang","followers_url":"https://api.github.com/users/TingluoHuang/followers","following_url":"https://api.github.com/users/TingluoHuang/following{/other_user}","gists_url":"https://api.github.com/users/TingluoHuang/gists{/gist_id}","starred_url":"https://api.github.com/users/TingluoHuang/starred{/owner}{/repo}","subscriptions_url":"https://api.github.com/users/TingluoHuang/subscriptions","organizations_url":"https://api.github.com/users/TingluoHuang/orgs","repos_url":"https://api.github.com/users/TingluoHuang/repos","events_url":"https://api.github.com/users/TingluoHuang/events{/privacy}","received_events_url":"https://api.github.com/users/TingluoHuang/received_events","type":"User","site_admin":false},"prerelease":false,"created_at":"2017-11-27T21:22:07Z","published_at":"2017-11-27T22:15:37Z","assets":[],"tarball_url":"https://api.github.com/repos/Microsoft/vsts-agent/tarball/v2.126.0","zipball_url":"https://api.github.com/repos/Microsoft/vsts-agent/zipball/v2.126.0","body":"## Features\\r\\n - Consume Git 2.14.3. #1295\\r\\n - Process cleanup enhance. #1292\\r\\n\\r\\n## Bugs\\r\\n  - Fix artifacts to be downloaded by agent. #1289\\r\\n\\r\\n## Misc\\r\\n  - Collect PowerShell version in diagnostic log. #1296 \\r\\n\\r\\n## Agent Downloads  \\r\\n\\r\\n|         | Package                                                                                                       |\\r\\n| ------- | ----------------------------------------------------------------------------------------------------------- |\\r\\n| Windows | [vsts-agent-win-x64-2.126.0.zip](https://vstsagentpackage.azureedge.net/agent/2.126.0/vsts-agent-win-x64-2.126.0.zip)      |\\r\\n| macOS   | [vsts-agent-osx-x64-2.126.0.tar.gz](https://vstsagentpackage.azureedge.net/agent/2.126.0/vsts-agent-osx-x64-2.126.0.tar.gz)   |\\r\\n| Linux   | [vsts-agent-linux-x64-2.126.0.tar.gz](https://vstsagentpackage.azureedge.net/agent/2.126.0/vsts-agent-linux-x64-2.126.0.tar.gz) |\\r\\n\\r\\nAfter Download:  \\r\\n\\r\\n## Windows\\r\\n\\r\\n``` bash\\r\\nC:\\\\> mkdir myagent && cd myagent\\r\\nC:\\\\myagent> Add-Type -AssemblyName System.IO.Compression.FileSystem ; [System.IO.Compression.ZipFile]::ExtractToDirectory(\\"$HOME\\\\Downloads\\\\vsts-agent-win-x64-2.126.0.zip\\", \\"$PWD\\")\\r\\n```\\r\\n\\r\\n## OSX\\r\\n\\r\\n``` bash\\r\\n~/$ mkdir myagent && cd myagent\\r\\n~/myagent$ tar xzf ~/Downloads/vsts-agent-osx-x64-2.126.0.tar.gz\\r\\n```\\r\\n\\r\\n## Linux\\r\\n\\r\\n``` bash\\r\\n~/$ mkdir myagent && cd myagent\\r\\n~/myagent$ tar xzf ~/Downloads/vsts-agent-linux-x64-2.126.0.tar.gz\\r\\n```\\r\\n"}'

    xit 'returns the new url' do
      expect(latest_release(response_body)).to eq 'https://vstsagentpackage.azureedge.net/agent/2.126.0/vsts-agent-osx-x64-2.126.0.tar.gz'
    end
  end

  context 'when the version is pinned' do
    it 'returns the correct url' do
      expect(release_download_url('2.126.0')).to eq 'https://vstsagentpackage.azureedge.net/agent/2.126.0/vsts-agent-osx-x64-2.126.0.tar.gz'
    end
  end
end
