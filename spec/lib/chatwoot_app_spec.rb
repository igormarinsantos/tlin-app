require 'rails_helper'

RSpec.describe ChatwootApp do
  describe '.captain_enabled?' do
    before do
      allow(described_class).to receive(:enterprise?).and_return(true)
    end

    it 'is disabled by default' do
      with_modified_env CAPTAIN_ENABLED: nil do
        expect(described_class.captain_enabled?).to be(false)
      end
    end

    it 'is enabled only when explicitly configured' do
      with_modified_env CAPTAIN_ENABLED: 'true' do
        expect(described_class.captain_enabled?).to be(true)
      end
    end
  end
end
