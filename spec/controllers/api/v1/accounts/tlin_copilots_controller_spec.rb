require 'rails_helper'

RSpec.describe 'Tlin Copilot API', type: :request do
  let(:account) { create(:account) }
  let(:admin) { create(:user, account: account, role: :administrator) }
  let(:conversation) { create(:conversation, account: account) }

  it 'returns a human-review suggestion for an authorized conversation' do
    service = instance_double(TlinCopilot::SuggestionService, perform: { suggestion: 'Sugestão de teste.', usage: {} })
    allow(TlinCopilot::SuggestionService).to receive(:new).and_return(service)

    post "/api/v1/accounts/#{account.id}/tlin_copilot",
         headers: admin.create_new_auth_token,
         params: { conversation_id: conversation.display_id, skill: 'resposta' },
         as: :json

    expect(response).to have_http_status(:success)
    expect(response.parsed_body).to include('suggestion' => 'Sugestão de teste.')
  end

  it 'does not find a conversation from another account' do
    other_conversation = create(:conversation)
    other_conversation.update!(display_id: 999_999)

    post "/api/v1/accounts/#{account.id}/tlin_copilot",
         headers: admin.create_new_auth_token,
         params: { conversation_id: other_conversation.display_id, skill: 'resposta' },
         as: :json

    expect(response).to have_http_status(:not_found)
  end
end
