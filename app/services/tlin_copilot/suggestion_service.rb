class TlinCopilot::SuggestionService
  MAX_MESSAGES = 30
  MAX_MESSAGE_CHARACTERS = 2_000
  MAX_OUTPUT_TOKENS = 500

  class ConfigurationError < StandardError; end
  class InvalidSkillError < StandardError; end
  class UnavailableError < StandardError; end

  def initialize(account:, conversation:, skill_key:)
    @account = account
    @conversation = conversation
    @skill = TlinCopilot::SkillRegistry.fetch(skill_key)
  end

  def perform
    raise InvalidSkillError, 'Skill do Copiloto Tlin inválida.' unless skill
    raise ConfigurationError, 'OPENAI_API_KEY ausente.' if api_key.blank?

    response = client.chat(parameters: request_parameters)
    raise UnavailableError, response.dig('error', 'message').presence || 'OpenAI retornou um erro.' if response['error']

    suggestion = response.dig('choices', 0, 'message', 'content').to_s.strip
    raise UnavailableError, 'A OpenAI não retornou uma sugestão.' if suggestion.blank?

    usage = response.fetch('usage', {}).slice('prompt_tokens', 'completion_tokens', 'total_tokens')
    log_usage(usage)
    { suggestion: suggestion, usage: usage }
  rescue Faraday::Error => e
    raise UnavailableError, e.message
  end

  private

  attr_reader :account, :conversation, :skill

  def api_key
    ENV.fetch('OPENAI_API_KEY', nil)
  end

  def client
    @client ||= OpenAI::Client.new(
      access_token: api_key,
      request_timeout: ENV.fetch('TLIN_COPILOT_TIMEOUT_SECONDS', 20).to_i
    )
  end

  def request_parameters
    {
      model: ENV.fetch('TLIN_COPILOT_MODEL', 'gpt-4o-mini'),
      max_tokens: MAX_OUTPUT_TOKENS,
      temperature: 0.4,
      messages: [
        { role: 'system', content: system_prompt },
        { role: 'user', content: conversation_transcript }
      ]
    }
  end

  def system_prompt
    <<~PROMPT.squish
      Você é o Copiloto SDR do Tlin. Ajuda um atendente humano e nunca envia mensagens por conta própria.
      Responda somente em português brasileiro. Não invente informações que não estejam no histórico.
      #{skill.prompt}
    PROMPT
  end

  def conversation_transcript
    messages = conversation.messages.chat.reorder(created_at: :desc).limit(MAX_MESSAGES).reverse
    history = messages.filter_map do |message|
      content = message.content.to_s.squish.truncate(MAX_MESSAGE_CHARACTERS)
      next if content.blank?

      "#{speaker_for(message)}: #{content}"
    end

    "Histórico da conversa:\n#{history.join("\n")}"
  end

  def speaker_for(message)
    return 'Cliente' if message.incoming?

    'Atendente'
  end

  def log_usage(usage)
    Rails.logger.info(
      {
        event: 'tlin_copilot.usage',
        account_id: account.id,
        conversation_id: conversation.display_id,
        skill: skill.key,
        model: ENV.fetch('TLIN_COPILOT_MODEL', 'gpt-4o-mini'),
        **usage
      }.to_json
    )
  end
end
