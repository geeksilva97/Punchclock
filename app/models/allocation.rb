# frozen_string_literal: true

class Allocation < ApplicationRecord
  belongs_to :user
  belongs_to :project
  belongs_to :company

  monetize :hourly_rate_cents

  validates :user, :project, :start_at, :end_at, presence: true
  validates_date :start_at
  validates_date :end_at, after: ->(a) { a.start_at }
  validate :unique_period, unless: :end_before_start?
  validates :ongoing, uniqueness: { scope: :user, message: :uniqueness },
                      if: :ongoing?

  delegate :office_name, to: :user

  scope :ongoing, -> { 
    where(ongoing: true, user_id: User.active).order(start_at: :desc)
  }
  scope :finished, -> {
    where(ongoing: false, user_id: User.active).order(end_at: :desc) }
  scope :in_period, -> (start_at, end_at) do
    where(
      "daterange(start_at, end_at, '[]') && daterange(:start_at, :end_at, '[]')",
      start_at: start_at,
      end_at: end_at
    )
  end

  def days_until_finish
    return unless end_at

    if ongoing
      (end_at - Date.current).to_i
    elsif end_at > Time.zone.today
      I18n.t('not_started')
    else
      I18n.t('finished')
    end
  end

  def user_punches
    project
      .punches
      .where(user: user)
      .since(start_at)
      .order(from: :desc)
      .decorate
  end

  private

  def end_before_start?
    end_at.present? && end_at < start_at
  end

  def unique_period
    return unless Allocation.in_period(start_at, end_at).where.not(id: id).exists?(user_id: user_id)
  
    errors.add(:start_at, :overlapped_period)
  end
end
