class Course
  include Mongoid::Document
  include Mongoid::Timestamps::Short

  field :title
  field :lang
  field :status, type: Integer, default: 3
  field :tags, type: Array
  field :content
  field :raw_content, default: ""
  field :script, type: Array
  
  # author
  belongs_to :member

  validates :title, presence: true, uniqueness: {scope: :member}

  scope :en,where(lang: nil)

  PRICE = 7
  WORDS_LIMIT = 40

  STATUS = {
    open: 1,
    ready: 2,
    draft: 3
  }
  # 1 : 发布状态 不能被修改，否则变为 3
  # 2 : 审核状态 不能修改，－>1 ->3
  # 3 : 草稿状态 默认
  STATUS.each do |k,v|
    scope k,where(status: v)
  end

  def price
    PRICE
  end

  def words_in_content
    raw_content.scan(/<b>([^<\/]*)<\/b>/).flatten.uniq
  end

  def words
    Word.where(:title.in => words_in_content)
  end

  def tests
    $redis.hmset("course_#{_id}",words.map{|x| [x.title,x.content]}.flatten)
  end

  def prepare_words
    words_in_content.each do |w|
      Onion::Word.new(w).insert(skip_exist: 1)
    end
  end

  def make_draft(title,tags,content)
    self.title = title
    self.tags = tags.split(",")
    self.content = content
    self.raw_content = content.split("\r\n").map{|s| "<div>#{s}</div>"}.join()
    self.status = STATUS[:draft]
    self.save!
  end

  # 标记课程状态为审核中
  def make_ready(raw_content)
    self.raw_content = raw_content   
    if words_in_content.length <= WORDS_LIMIT
      self.status = STATUS[:ready]
      self.save!
    else
      return false
    end
  end

  def make_open
    self.update_attribute(:status,STATUS[:open])
    unless self.member.has_checkin?(self.id)
      self.member.course_grades << CourseGrade.new(course_id: self.id)
    end
    HardWorker::PrepareWordJob.perform_async(self._id.to_s)
  end

  def as_json
    ext = {
      author: {
        name: member.name,
        url: member.member_path
      },
      tags: tags.join(","),
      wl: words_in_content.length,
      stat: Hash[STATUS.map{|k,v| [v,k]}][status],
      _id: id.to_s
    }
    super(only: [:title,:content,:raw_content,:u_at,:status]).merge(ext)
  end

  rails_admin do
    list do 
      field :status
      field :title
      field :member
    end
    edit do 
      field :status, :integer
      field :title
      field :content , :text
      field :raw_content, :text
    end
    show do 
      configure :raw_content do 
        pretty_value do 
          bindings[:view].raw value
        end
      end
    end
  end

  index({ title: 1})
  index({ tags: 1})

end
