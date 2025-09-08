# app/models/sleep_record.rb
class SleepRecord < ApplicationRecord
    belongs_to :user
    
    validates :started_at, presence: true
    validate :ended_after_started
    
    scope :open_records, -> { where(ended_at: nil) }
    scope :closed_records, -> { where.not(ended_at: nil) }
    
    before_save :compute_duration
    
    def duration
        return duration_sec if duration_sec
        return nil unless ended_at && started_at
        (ended_at - started_at).to_i
    end
    
    private
    def ended_after_started
        return if ended_at.blank?
        errors.add(:ended_at, 'must be after started_at') if ended_at <= started_at
    end
    
    def compute_duration
        if ended_at.present?
            self.duration_sec = (ended_at - started_at).to_i
        end
    end
end