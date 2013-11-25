require 'helpers'
require 'speech'

class Icard < Grape::API
	prefix 'api'
	format :json

	helpers APIHelpers

	before do
		authenticated_device?
	end

	resource :members do
		desc "register or login"
		get "/" do
			unless current_device
				current_device = DeviceMember.generate("17Word",params.slice(:uuid,:name,:platform))
			end
			if current_device.member
				render_json 0,"ok",current_device.member.as_profile
			else
				render_json 0,"ok",current_device.as_json
			end
		end

		# @params token
		# @params uuid
		desc "bind device uuid and member"
		post :bind do
			if member = Member.authorize(params[:token])
				current_device.update_attribute(:member_id,member.id)
				render_json 0,"ok",member.as_profile
			else
				render_json -1,"error token"
			end
		end
	end

	resource :cards do

		# 随版本更新后，某些词汇详情的客户端数据同步更新
		# 不会很多，属于数据修正,后端定义
		desc "repair some word info"
		get :repair do
			# words = Word.where(:id => "")
			# render_json 0,"ok",words.as_json
		end

		# 从数据库搜索 title，如无则从web上搜
		desc "search one word from web"
		get :search do


		end

		# @params uuid
		desc "avatar upload"
		post :avatar do
			current_member = current_device.member
			file = params[:image].tempfile.path
			type = params[:image].content_type || params[:image].type
			if current_member.validate_upload_avatar(file,type)
				current_member.save_avatar(file)
				@avatar = current_member.avatar + "?#{Time.now.to_i}"
				render_json 0,"ok",@avatar
			else
				render_json -1,"error"
			end
		end

		# 联想相关词汇卡片
		desc "imagine u_word by specify word limit 4"
		get :imagine do
			word = Word.find(params[:id])
			limit = params[:limit] || 4
			data = word.u_words.has_image.desc(:u_at).limit(limit).as_json
			render_json 0,"ok", data
		end
		# 加赞
		desc "add good for u_word"
		get :good do
			uw = UWord.find(params[:id])
			uw.good = uw.good + 1
			uw.save
			render_json 0,"ok"
		end

		# @params async 异步图片合成，适用于同步功能
		# 否则实时处理合成图片，适用于分享功能
		desc "make one word card no share params[:async]"
		post :create do
			@uw = find_or_create_uw(params[:_id])
			file = params[:image].tempfile.path
			type = params[:image].content_type || params[:image].type
			if @uw&&@uw.validate_upload_image(file,type)
				if params[:async]
					file = Tempfile.new(@uw.id.to_s).path
					File.open(file, 'wb') do |f|
						f.write params[:image].read
					end
					HardWorker::ProcessImageJob.perform_async(@uw._id.to_s,file)
				else
					@uw = @uw.make_image(file)
				end
				@uw.geo = [params[:lat],params[:lng]]
				@uw.altitude = params[:altitude].to_f
				@uw.cap_at = Time.parse params[:cap_at]
				@uw.save
				render_json 0,"ok",@uw.image_url
			else
				render_json -1,"error"
			end
		end

		desc "upload audio"
		post :audio do
			@uw = find_or_create_uw(params[:_id])
			# wav file
			file = params[:file].tempfile.path
			audio = Speech::AudioToText.new(file)
			# resp = audio.to_json
			# resp["hypotheses"][0]
			# singularize / pluralize
			begin
				text = audio.to_text.downcase
				Rails.logger.info text
				if correct = text == @uw.title
					@uw.make_audio(file)
				end
				data = {
					correct: correct,
					text: text
				}
				render_json 0,"ok",data
			rescue => ex
				Rails.logger.info ex.to_s
				render_json -1,"error"
			end
		end
	end

end
