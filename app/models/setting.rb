# frozen_string_literal: true

# == Schema Information
#
# Table name: patchwork_settings
#
#  id         :bigint           not null, primary key
#  app_name   :integer          default("bristol_cable"), not null
#  settings   :jsonb
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  account_id :bigint           not null
#
# Indexes
#
#  index_patchwork_settings_on_account_id  (account_id)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id) ON DELETE => cascade
#
class Setting < ApplicationRecord
  self.table_name = 'patchwork_settings'

  belongs_to :account, class_name: 'Account'

  validates :account, presence: true, uniqueness: { scope: :app_name, case_sensitive: false }
  validates :app_name, presence: true
  validates :settings, presence: true
  validate :validate_user_timeline

  enum app_name: { bristol_cable: 0 }, _default: :bristol_cable

  # Define valid user timeline options
  USER_TIMELINE_OPTIONS = { following: 1, community: 2, for_you: 3 }.freeze
  VALID_USER_TIMELINE_VALUES = USER_TIMELINE_OPTIONS.values.freeze

  private

    def validate_user_timeline
      return unless settings&.dig('user_timeline')

      user_timeline = settings['user_timeline']
      
      unless user_timeline.is_a?(Array)
        errors.add(:settings, 'user_timeline must be an array')
        return
      end

      invalid_values = user_timeline - VALID_USER_TIMELINE_VALUES
      if invalid_values.any?
        errors.add(:settings, "user_timeline contains invalid values: #{invalid_values.join(', ')}. Valid values are: #{USER_TIMELINE_OPTIONS}")
      end
    end


end
