require 'rails_helper'

RSpec.describe TlinCopilot::SuggestionService do
  let(:account) { create(:account) }
  let(:inbox) { create(:inbox, account: account) }
  let(:conversation) { create(:conversation, account: account, inbox: inbox) }
  let(:client) { instance_double(OpenAI::Client) }

  before do
    create(:message, account: account, inbox: inbox, conversation: conversation, content: 'Quero saber o valor do serviço.', message_type: :incoming)
    create(:message, account: account, inbox: inbox, conversation: conversation, content: 'Posso explicar as opções.', message_type: :outgoing)
    create(:message, account: account, inbox: inbox, conversation: conversation, content: 'Nota interna que não deve sair.', private: true)
  end

  it 'supports every registered SDR skill with only public conversation history' do
    allow(OpenAI::Client).to receive(:new).and_return(client)
    expect(client).to receive(:chat).exactly(3).times do |parameters:|
      transcript = parameters[:messages].last[:content]
      expect(transcript).to include('Cliente: Quero saber o valor do serviço.')
      expect(transcript).to include('Atendente: Posso explicar as opções.')
      expect(transcript).not_to include('Nota interna')

      {
        'choices' => [{ 'message' => { 'content' => 'Pergunte qual plano atende melhor.' } }],
        'usage' => { 'prompt_tokens' => 120, 'completion_tokens' => 18, 'total_tokens' => 138 }
      }
    end

    %w[resumir objecao resposta].each do |skill_key|
      result = nil
      with_modified_env OPENAI_API_KEY: 'test-key' do
        result = described_class.new(account: account, conversation: conversation, skill_key: skill_key).perform
      end

      expect(result).to eq(
        suggestion: 'Pergunte qual plano atende melhor.',
        usage: { 'prompt_tokens' => 120, 'completion_tokens' => 18, 'total_tokens' => 138 }
      )
    end
  end

  it 'rejects an unknown skill before calling OpenAI' do
    with_modified_env OPENAI_API_KEY: 'test-key' do
      service = described_class.new(account: account, conversation: conversation, skill_key: 'desconhecida')

      expect { service.perform }.to raise_error(described_class::InvalidSkillError)
    end
  end
end
