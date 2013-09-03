module HardWorker
  class Base
    include Sidekiq::Worker
    sidekiq_options retry: false

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

  class SendInviteJob < Base
    def perform(message,id)
      provider = Authorization.find(id)
      case provider.provider
      when "weibo"
        Wali::Base.new(provider).client.statuses_update(message)
      when "twitter"
        Wali::Base.new(provider).client.update(message)
      when "qq_connect"
        #To-Do
      end
    end
  end

  # Be Removed
  class UploadOlive < Base

    def perform(content,pic)
      begin
        p = Authorization.official("weibo")
        data = Wali::Base.new(p).client.statuses_upload(content,pic)
				msg = data["error_code"] ? data.to_s : "#{data["id"]} published"
				self.logger msg
      rescue => ex
        self.logger("#{content} [#{pic}] fail msg: #{ex.to_s}")
      end
      #twitter
      veggie = Authorization.official("twitter")
      Wali::Base.new(veggie).client.update_with_media(content,File.open(pic))
    end
  end

end
