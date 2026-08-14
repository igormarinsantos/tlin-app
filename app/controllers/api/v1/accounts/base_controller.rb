class Api::V1::Accounts::BaseController < Api::BaseController
  include SwitchLocale
  include EnsureCurrentAccountHelper
  before_action :current_account
  before_action :ensure_trial_active
  around_action :switch_locale_using_account_locale

  private

  def ensure_trial_active
    return unless current_user && Current.account && !Current.account.trial_active?

    render json: { error: 'Trial expired. Activate a plan to continue.' }, status: :payment_required
  end
end
