module Concerns
  module Likeable
    extend ActiveSupport::Concern

    included do
      field :liked_member_ids, type: Array, default: []
    end

    def liked_by?(member)
      return false if member.blank?
      self.liked_member_ids.include?(member._id)
    end

    def liked_by(member)
      unless liked_by?(member)
        self.liked_member_ids << member._id
        member.send("#{self.to_s.downcase}_ids") << self._id
        member.save
        self.save
      end
    end

    def liked_count
      self.liked_member_ids.length
    end
  end
end