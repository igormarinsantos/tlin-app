class TlinCopilot::SkillRegistry
  Skill = Data.define(:key, :prompt)

  SKILLS = {
    'resumir' => Skill.new(
      key: 'resumir',
      prompt: 'Resuma esta conversa de atendimento em bullets objetivos: o que o cliente quer, o que já foi respondido e o que falta resolver.'
    ),
    'objecao' => Skill.new(
      key: 'objecao',
      prompt: 'Identifique a principal objeção ou hesitação do cliente nesta conversa e sugira 1-2 formas de contorná-la, ' \
              'em tom consultivo brasileiro.'
    ),
    'resposta' => Skill.new(
      key: 'resposta',
      prompt: 'Sugira a próxima mensagem que o atendente deveria enviar para avançar esta venda, em português brasileiro, ' \
              'tom natural de WhatsApp, sem parecer robô.'
    )
  }.freeze

  def self.fetch(key)
    SKILLS[key.to_s]
  end
end
