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
end
