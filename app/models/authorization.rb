class Authorization
  include Mongoid::Document
  include Mongoid::Timestamps::Short

  field :provider
  field :uid, type: String
  field :token
  field :secret
  field :refresh_token
  field :expired_at, type: Time
  field :info, type: Hash

  validates :provider, presence: true
  validates :uid, presence: true, uniqueness: {scope: :provider}
  belongs_to :member
  after_create :send_greet

  PROVIDERS = %w{qq_connect weibo twitter github instagram youtube}

  def self.official(provider)
    Authorization.where(provider: provider).first
  end

  def avatar(style = :mudium)
    image = info['image'] || info['avatar']
    case style
    when :mudium
      image
    when :large
      case provider
      when "weibo"
        image.gsub("/50/","/180/")
      when "twitter"
        image.gsub("_normal","")
      when "tumblr"
        image.gsub("_64","_512")
      else
        image
      end
    end
  end

  def send_greet
		if self.member.authorizations.length == 1
		  # 注册 save avatar from provider
		  self.member.save_avatar(avatar(:large))
		end
    HardWorker::SendGreetJob.perform_async(self._id.to_s)
  end

  # @twitter @weibo
  def at_name
    info['nickname']
  end

  def user_name
    info['name'] || at_name
  end

  def link
    case provider
    when "weibo"
      link = info['urls']['Weibo']
      link.blank? ? "http://weibo.com/#{uid}" : link
    when "twitter"
      info['urls']['Twitter']
    when "tumblr"
      info['blogs'][0]['url']
    when "instagram"
      "http://instagram.com/#{at_name}"
    when "github"
      info['urls']['GitHub']
    when "youtube"
      info['channel_url']
    end
  end

  def check_expired
    if expired_at && (expired_at < Time.current)
      return false
    else
      return true
    end
  end

  def as_json
    ext = {
      link: link,
      name: user_name,
      avatar: avatar
    }
    super(only: [:provider,:_id,:expired_at]).merge(ext)
  end

  rails_admin do
    field :provider do
      pretty_value do
        bindings[:view].link_to(value,bindings[:object].link)
      end
    end
    field :uid
    field :member
  end

  index({ provider: 1,uid: 1},{ unique: true })

end
