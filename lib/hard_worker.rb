module HardWorker
	class Base
		include Sidekiq::Worker
		sidekiq_options retry: 4

		def logger(msg)
			Logger.new(File.join(Rails.root,"log","sidekiq-job.log")).info("[#{self.class}] #{msg}")
		end
	end

	class SendGreetJob < Base
		def perform(id, opts={})
			provider = Authorization.find(id)
			self.logger(provider.user_name)
			Wali::Greet.new(provider,opts).deliver
		end
	end

	class PrepareWordJob < Base
		def perform(cid)
			words_count = Course.find(cid).prepare_words.length
			self.logger("#{words_count} words prepared")
		end
	end

	class ProcessImageJob < Base
		def perform(wid,file)
			uword = UWord.find(wid).make_image(file)
			uword.save
			self.logger("uword #{wid} completed")
		end
	end

	class SendInviteJob < Base
		def perform(message,id)
			provider = Authorization.find(id)
			case provider.provider
			when "weibo"
				Wali::Base.new(provider).client.statuses_update(message)
			when "twitter"
				Wali::Base.new(provider).client.update(message)
			when "qq_connect"
				Wali::Base.new(provider).client.add_t(message)
			end
		end
	end

	class UploadOlive < Base

		def perform(content,pic,id)
			provider = Authorization.find(id)
			begin
				case provider.provider
				when "weibo"
					Wali::Base.new(provider).client.statuses_upload(content,pic)
				when "twitter"
					Wali::Base.new(provider).client.update_with_media(content,File.open(pic))
				when "qq_connect"
					Wali::Base.new(provider).client.add_pic_t(content,File.open(pic))
				end
			rescue => ex
				self.logger("#{content} [#{pic}] fail msg: #{ex.to_s}")
			end
		end
	end

end
