class MobileController < ApplicationController

	def index
		set_seo_meta(t('mobile.title'),t('keywords'),t('describe'))
	end

	def fetch
		if current_member[:tumblr].nil? || params[:reload]
			Eva::Media.new(current_member).fetch
		end
		data = {
			tumblr: (current_member[:tumblr] || [])
		}
		render_json 0,"ok",data
	end

	def make_word
		word = Onion::Word.new(params[:title].strip).insert(skip_exist: 1)
		unless @uw = current_member.has_u_word(word)
			@uw = current_member.u_words.new(word_id: word._id)
		end
		if current_member.tumblr.include?(params[:url])
			@uw = @uw.make_image(params[:url])
			@uw.img_info = "tumblr like"
			@uw.save
			img = @uw.image_url + "?#{Time.now.to_i}"
			render_json 0,t("flash.success.upload.uword"),img
		else
			render_json -1,"not found url"
		end
	end

end
