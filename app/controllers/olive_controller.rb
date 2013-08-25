class OliveController < ApplicationController
	before_filter :authenticate_admin

	def index
		set_seo_meta("Olive",t('keywords'),t('describe'))
	end
	# get
	def courses
		status = params[:status] || "ready"
		@courses = Course.send(status).desc("u_at").as_json
		data = {
			courses: @courses
		}
		render_json 0,"ok",data
	end

	# get
	def songs
		@songs = Song.desc("_id").limit(5)
		data = {
			songs: @songs.collect(&:as_json)
		}
		render_json 0,"ok",data
	end

	# get
	def quotes
		if params[:author]
			@quotes = Quote.author_by params[:author]
			data = {
				quotes: @quotes.as_json(only: [:_id,:content,:tags,:author])
			}
		else
			data = {
				tags: {
					count: Quote.tags.count,
					top: Quote.tags_list(down: 2)[0..199]
				}
			}
		end
		render_json 0,'ok',data
	end

	# post
	def create_quote
		if author = Onion::Quote.new.get_author(params[:author])
			msg = Onion::Quote.new(author: author).fetch
			Quote.tags_list(clear: true)
		else
			msg = "no author"
		end
		render_json 0,msg	
	end

	# single tag delete
	def destroy_tag
		@quotes = Quote.where(tags: params[:tag]) 
		count = @quotes.count
		if count != 0
			@quotes.each do |q|
				q.tags.delete params[:tag]
				q.save
			end
			Quote.tags_list(pop: params[:tag])
		end
		render_json 0,'ok',count
	end

	private
  	def authenticate_admin
    	unless current_member and current_member.admin?
      		redirect_to new_member_session_path(admin: 1)
    	end
  	end

	def photos(provider,title)
		provider.new.tagged(title).map{|x| x[:photo] }
	end
end
