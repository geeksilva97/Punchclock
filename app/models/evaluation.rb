# frozen_string_literal: true

class Evaluation < ApplicationRecord
  extend Enumerize
  SCORE_RANGE = (1..10).to_a.freeze

  after_create :update_office_score

  belongs_to :evaluated, class_name: 'User'
  belongs_to :evaluator, class_name: 'User'
  belongs_to :questionnaire
  has_many   :answers, dependent: :destroy

  accepts_nested_attributes_for :answers

  delegate :english?, to: :questionnaire

  validates :evaluated, :evaluator, :questionnaire, :score, :evaluation_date, presence: true
  validates :score, inclusion: { in: SCORE_RANGE }
  validates :english_level, presence: true, if: :english?

  attribute :evaluation_date, :date, default: Time.zone.today

  scope :by_kind, -> (kind) { joins(:questionnaire).merge(Questionnaire.public_send(kind)) }

  enumerize :english_level, in: {
    beginner: 0, intermediate: 1, advanced: 2, fluent: 3
  },  scope: :shallow,
      predicates: true

  private

  def update_office_score
    evaluated.office.calculate_score
  end
end
