class Api::V1::Accounts::OnboardingsController < Api::V1::Accounts::BaseController
  before_action :check_admin_authorization?

  def update
    @account = Current.account
    finalize = finalizing_tlin_onboarding?
    return render_invalid_tlin_lead_data if finalize && !valid_tlin_lead_data?

    @account.assign_attributes(account_params)
    @account.custom_attributes.merge!(custom_attributes_params)
    complete_tlin_onboarding! if finalize
    @account.save!

    # TODO: re-enable when the help center generation UI is ready to surface progress
    # Onboarding::HelpCenterCreationService.new(@account, Current.user).perform if finalize && website.present?

    render 'api/v1/accounts/update', format: :json
  end

  def help_center_generation
    render json: help_center_generation_status
  end

  private

  def finalizing_tlin_onboarding?
    @account.custom_attributes['onboarding_step'].in?(%w[account_details enrichment])
  end

  def valid_tlin_lead_data?
    custom_attributes_params[:lead_contact_name].present? &&
      custom_attributes_params[:lead_whatsapp].to_s.match?(/\A\+[1-9]\d{7,14}\z/)
  end

  def render_invalid_tlin_lead_data
    render json: { error: 'lead_contact_name and lead_whatsapp are required' }, status: :unprocessable_entity
  end

  def complete_tlin_onboarding!
    # These Account custom attributes are the source for lead export today and
    # future fazer-ai/agents provisioning; keep the keys stable for both uses.
    @account.custom_attributes['onboarding_completed'] = true
    @account.custom_attributes.delete('onboarding_step')
  end

  def website
    custom_attributes_params[:website]
  end

  def account_params
    params.permit(:name, :locale)
  end

  def custom_attributes_params
    params.permit(
      :industry,
      :company_size,
      :timezone,
      :referral_source,
      :user_role,
      :website,
      :lead_contact_name,
      :lead_whatsapp,
      :business_type,
      :business_offer
    )
  end

  def help_center_generation_status
    {
      generation_id: nil,
      state: nil,
      articles_count: 0,
      categories_count: 0
    }
  end
end

Api::V1::Accounts::OnboardingsController.prepend_mod_with('Api::V1::Accounts::OnboardingsController')
