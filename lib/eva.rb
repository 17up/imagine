module Eva
	class Base
		def initialize(member)
			@member = member
		end
	end

	class Course < Base
		def list
			# 推荐课程，在已发布课程中做推荐筛选
			recommands = ::Course.open.limit(2)
			# 正在学习的课程，学完并通过考核的课程不显示
			checked = @member.checked_courses
			invited = @member.invited_courses
			list = (checked + recommands + invited).uniq
			result = []
			list.each_with_index do |c,i|
				result << c.as_json.merge!(:has_checkin => (i < checked.length))
			end
			result
		end

	end

	class Quote < Base
		def single
			@quote = ::Quote.tag_by("love").desc("u_at").first
			@quote.as_short_json if @quote
		end

		def collection(tag = "love")
			@quotes = ::Quote.tag_by(tag).desc("u_at").limit(50)
			@quotes.map(&:as_short_json)
		end
		
	end

	class Song < Base
		def single
			@song = ::Song.desc("u_at").first
			liked = @song.liked_by?(@member)
			@song.as_json.merge!(:liked => liked)
		end
	end

	class Game < Base
		def single
			missions = @member.checked_courses.collect{|x| x.words}.flatten.uniq
			{
				num: missions.length,
				data: missions.map(&:as_json)
			}
		end

	end

	class Media < Base
		def fetch
			if p = @member.has_provider?("tumblr")
				data = Olive::Tumblr.new(p).user_liked_media
				if @member[:tumblr]
					data =  data | @member[:tumblr]
				end
				@member.write_attribute(:tumblr,data)
				@member.save
			end
		end
		
	end
end