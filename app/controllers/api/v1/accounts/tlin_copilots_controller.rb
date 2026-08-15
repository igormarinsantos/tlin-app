class Api::V1::Accounts::TlinCopilotsController < Api::V1::Accounts::BaseController
  def create
    conversation = Current.account.conversations.find_by!(display_id: copilot_params[:conversation_id])
    authorize conversation, :show?

    result = TlinCopilot::SuggestionService.new(
      account: Current.account,
      conversation: conversation,
      skill_key: copilot_params[:skill]
    ).perform

    render json: result
  rescue TlinCopilot::SuggestionService::InvalidSkillError => e
    render json: { error: e.message }, status: :unprocessable_entity
  rescue TlinCopilot::SuggestionService::ConfigurationError => e
    Rails.logger.error("Tlin Copilot configuration error: #{e.message}")
    render json: { error: 'O Copiloto Tlin ainda não está configurado.' }, status: :service_unavailable
  rescue TlinCopilot::SuggestionService::UnavailableError => e
    Rails.logger.warn("Tlin Copilot unavailable: #{e.message}")
    render json: { error: 'O Copiloto Tlin não está disponível agora. Tente novamente em instantes.' }, status: :service_unavailable
  end

  private

  def copilot_params
    params.permit(:conversation_id, :skill)
  end
end
