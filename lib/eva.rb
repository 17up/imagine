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

		def list(tag,num)
			@quotes = ::Quote.tag_by(tag).desc("u_at").limit(num)
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
		def list(opts = {})
			missions = @member.checked_courses.collect{|x| x.words}.flatten.uniq
			data = missions.map do |w|
				w.as_json.merge!(image: w.image)
			end
			{
				num: missions.length,
				data: data
			}
		end

	end

	class Icard < Base
		def list(num)
			Word.limit(num).map do |w|
				q = Quote.content_by(w.title).lt(100).limit(3).as_json(only: [:content])
				w.as_json.merge!(quotes: q)
			end
			#.group_by{|x| x['title'][0,1].downcase }
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
