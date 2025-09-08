# app/models/follow.rb
class Follow < ApplicationRecord
    belongs_to :follower, class_name: 'User'
    belongs_to :followed, class_name: 'User'
    
    validates :follower_id, uniqueness: { scope: :followed_id }
    validate :prevent_self_follow
    
    private
    def prevent_self_follow
        errors.add(:base, 'cannot follow yourself') if follower_id == followed_id
    end
end