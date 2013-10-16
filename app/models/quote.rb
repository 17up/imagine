class Quote < Text
	include Concerns::Likeable

	field :author, type: Hash
	field :source, type: Hash
	field :u_at, type: DateTime

	validates :content, uniqueness: true, presence: true
	validates :tags, presence: true
	validates :author, presence: true
	after_save :update_time

	BASE_URL = "http://www.goodreads.com"
	TAG_KEY = "quote_tags"

	scope :no_tag, -> {where(tags: nil)}
	scope :empty_tag, -> {where(:tags.with_size => 0)}
	scope :one_tag, -> {where(:tags.with_size => 1)}
	scope :with_author, -> {where(:author.exists => true)}
	scope :without_author, -> {where(author: nil)}
	scope :lt_100, -> {where("this.content.length < 100")}

	def update_time
		self.set(u_at: Time.current)
	end

	class << self
		def tag_by(tag_list,match_any = true)
			if match_any
				self.any_in(tags: tag_list.split(","))
			else
				self.all_in(tags: tag_list.split(","))
			end
		end

		def content_by(query)
			self.where(:content => /#{query}/)
		end

		def author_by author_name
			self.where('author.name' => author_name)
		end

		# output array 947.William_Shakespeare
		def authors(quotes = Quote.all)
			#Quote.distinct(:author).collect{|x| x["link"].split("/")[3]}
			quotes.pluck(:author).collect{|x| x["link"].split("/")[3]}.uniq
		end

		# output array
		def tags(quotes = Quote.all)
			quotes.pluck(:tags).flatten.uniq
		end

		# map reduce for tags
		def rebuild_tags
			map = %Q{
				function() {
					this.tags.forEach(function(t){
															emit(t, 1);
					});
				}
			}
			reduce = %Q{
				function(key,values) {
					var count = 0;
					values.forEach(function(v){
													 count += v;
					});
					return count;
				}
			}
			Quote.map_reduce(map,reduce).out(replace: "tags")
		end

		# 2th array [tag,num]
		# 条件：出现过2次以上的tag
		def tags_list(conditions = {})
			if conditions[:clear]
				Rails.cache.delete(TAG_KEY)
			end
			unless list = Rails.cache.read(TAG_KEY)
				list = Quote.rebuild_tags.map{|x| [x['_id'],x['value'].to_i]}
				Rails.cache.write(TAG_KEY,list)
			end
			if conditions[:up]
				list.select{|x| x[1] > conditions[:up]}
			elsif conditions[:down]
				list.select{|x| x[1] < conditions[:down]}
			elsif conditions[:pop]
				list.delete list.select{|x| x[0] == conditions[:pop]}[0]
				Rails.cache.write(TAG_KEY,list)
			else
				list
			end
		end
	end

	def as_short_json
		ext = {
			_id: id.to_s,
			author: author.merge('link' => BASE_URL + author['link'])
		}
		as_json(only: [:content]).merge(ext)
	end

	rails_admin do
		field :author do
			pretty_value do
				bindings[:view].link_to(value["name"],BASE_URL + value["link"])
			end
		end
		field :content,:text do
			pretty_value do
				bindings[:view].raw value
			end
		end
		field :u_at
		field :tags do
			pretty_value do
				value.blank? ? '-' : value.join(" / ")
			end
		end
		field :source do
			pretty_value do
				unless value.blank?
					bindings[:view].link_to(value["name"],BASE_URL + value["link"])
				end
			end
		end
	end

	index({"author.name" => 1})
	index({ tags: 1})
end
