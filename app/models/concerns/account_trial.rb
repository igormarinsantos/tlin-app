# frozen_string_literal: true

module AccountTrial
  TRIAL_DURATION = 7.days

  def trial_ends_at
    value = custom_attributes&.fetch('trial_ends_at', nil)
    Time.zone.parse(value) if value.present?
  rescue ArgumentError, TypeError
    nil
  end

  def plan_active?
    ActiveModel::Type::Boolean.new.cast(custom_attributes&.fetch('plan_active', false))
  end

  def trial_active?
    return true if plan_active?

    # Legacy accounts created before Tlin trials are not interrupted.
    trial_ends_at.blank? || trial_ends_at.future?
  end

  def trial_days_remaining
    return nil if plan_active? || trial_ends_at.blank?

    [(trial_ends_at.to_date - Time.zone.today).to_i, 0].max
  end
end
