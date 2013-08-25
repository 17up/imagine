module Olive
  SIDENAV = %w{tumblr instagram 500px}
  
  def upload(tag = "")
    @data = block_given? ? yield(self) : tagged(tag)
    @data.each do |p|     
      HardWorker::UploadOlive.perform_async("via #{self.class}",open(p).path)
    end
  end
  
  # Olive::Tumblr.new(Authorization.official("tumblr")).user_liked_media
  class Tumblr < Wali::Base

    def tagged(tag)
      data = client.tagged URI.encode(tag)
      @post = get_photos(data)		  
	    logger("From Tumblr --  Num: #{@post.length}; Tag: #{tag}")
	    @post
    end
    
    def user_media(blog_name)
      data = client.posts(blog_name,:type => "photo")["posts"]
      get_photos(data)
    end
    
    #[:limit, :offset]
    def user_liked_media(opts = {})
      data = client.likes(opts)["liked_posts"]
      get_photos(data)
    end

    private
    def get_photos(data)
      data.map do |d|
        if d["photos"]
          url = d["photos"][0]["original_size"]["url"]
          format = url.split(".")[-1]
          unless format == "gif"
            url.sub(/_\d+\./,"_400.")
          end
        end 
      end.compact
    end
  
  end
  
  class Instagram < Wali::Base
    
    def tagged(tag)
      resp = client.tag_recent_media(tag)
      @post = get_post(resp.data)
      logger("From Instagram --  Num: #{@post.length}; Tag: #{tag}")
      
      return @post
    end
    
    def popular
      resp = client.media_popular
      @post = get_post(resp)
    end
    
    def around(query)
      location = location(query)
      resp = client.media_search(location[:lat].to_s,location[:lng].to_s)
      @post = get_post(resp.data)
      logger("From Instagram --  Num: #{@post.length}; location: #{location[:address]}")
      
      return @post
    end
    
    # return lat/lng/id/name
    def location_search(query,opts={})
      if query
        location = location(query)
        data = client.location_search(location[:lat].to_s,location[:lng].to_s)
      else
        data = client.location_search(opts[:lat].to_s,opts[:lng].to_s)
      end
      data.to_json
    end
    
    def location_recent_media(id)
      resp = client.location_recent_media(id.to_i)
      @post = get_post(resp.data)
    end

		def user_media_feed
			resp = client.user_media_feed
			@post = get_post(resp.data)
		end
		
		def user_liked_media
		  resp = client.user_liked_media
		  @post = get_post(resp.data)
		end
    
    private
    def get_post(data)
			if data.is_a?(Array)
		    data.map do |x|    
		      x.images.standard_resolution.url
		    end
			end
    end
    
  end
  
  # methods
  # 1-photos
  # 2-tagged(tag)
  class Px < Wali::Base
		#require 'openssl'
    BASE_URL = 'https://api.500px.com'

    def initialize
      px = load_service["500px"]
      @ckey = px["app_key"]
      @csecret = px["app_secret"]
      @uname = px["user_name"]
      @pwd = px["password"]      
    end
    
    def photos(opt={})
    	options = {
    	  :image_size => 4,
				:feature => 'fresh_today'#'popular'/'upcoming'/'editors'
			}
			options.merge!(opt)
			@request = "/v1/photos?"+options.to_query
			@photos = get_photos(@request)
		end
		
		def tagged(tag,opt={})
		  options = {
		    :term => tag,
		    :image_size => 4
		  }
		  options.merge!(opt)
		  @request = "/v1/photos/search?"+options.to_query
		  @photos = get_photos(@request)
		end

		def get_access_token
			consumer = OAuth::Consumer.new(@ckey, @csecret, {
			:site               => BASE_URL,
			:request_token_path => "/v1/oauth/request_token",
			:access_token_path  => "/v1/oauth/access_token",
			:authorize_path     => "/v1/oauth/authorize"})

			request_token = consumer.get_request_token()
			#p "Request URL: #{request_token.authorize_url}"
			access_token = consumer.get_access_token(request_token, {}, { :x_auth_mode => 'client_auth', :x_auth_username => @uname, :x_auth_password => @pwd })
			access_token
		end

		def user
			access_token = get_access_token
			p "token: #{access_token.token}" 
			p "secret: #{access_token.secret}" 
			p MultiJson.decode(access_token.get('/v1/users.json').body)
		end
		
		private
		def get_photos(request)
		  access_token = get_access_token
			data = MultiJson.decode(access_token.get(request).body)["photos"]
			data.inject([]) do |a,x| 
				a << x["image_url"]
			end
		end
  end
  
  # 根据 olive 日志信息得到 最近100次搜索的 tag,按照次数降序返回结果
  # def self.parse_log
  #   log = "#{Rails.root}/log/olive.log"
  #   if File.exist? log
  #     tags = File.open(log,"r") do |f|		
  #   		f.readlines[-100..-1].map {|l| l.scan(/Tag\: (\S+)/).map{|x| $1}[0]	}		
  #   	end.compact
  #   	tags.uniq.map{ |x| 
  #   		[x,tags.grep(x).length]
  #   	}.sort!{|a,b| b[1] <=> a[1]}
		# else
		# 	[]
  # 	end
  #end
  
end
