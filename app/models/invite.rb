class Invite
  include Mongoid::Document
  include Mongoid::Timestamps::Short

  # 站内好友id
  field :target
  field :provider
  field :course_id

  belongs_to :member
  validates :target, uniqueness: {scope: [:member_id,:course_id]}, allow_nil: true
  validates :course_id, uniqueness: {scope: [:member_id,:provider]}, presence: true

  scope :outside, -> { where(:provider.exists => true)}
  scope :inside, -> { where(:provider.exists => false)}

  after_create :push_notify
  
  # 站内邀请发送push
  # 通知 target,member想和你一起学习某课
  def push_notify
  	if provider.nil?
      cname = Course.find(course_id).title
      message = I18n.t("invite.common",uname: member.name,cname: cname)
  		WebsocketRails["notify_#{target}"].trigger "invite_course",message
  	end
  end

  rails_admin do
    field :target
    field :provider
    field :course_id do 
      label "Course"
      pretty_value do
        Course.find(value).title
      end
    end
    field :member
  end

  index({target: 1})

end
