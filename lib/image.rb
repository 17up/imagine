# image function
module Image
  class Base
    include Utils::Service
    
    def img_save(url,output,success = -> { },&error)
      begin
        data = open(url){|f|f.read}
		    file = File.open(output,"wb") << data
        file.close
        success.call
				return 0
      rescue
				if block_given?
        	error.call
				else
					p "#{url} save fail!"
				end
				return -1
      end
    end
  end
  
  class Word < Base
    
    def initialize(title)
      @title = title
    end

    def parse(info="")
      title = URI.encode("#{@title} #{info}")
      @cid = load_service["bing"]["client_id"]
      @cpw = load_service["bing"]["client_secret"]
      @base_url = "https://api.datamarket.azure.com/Data.ashx/Bing/Search/v1/Image?Query='#{title}'&$format=json"
			url = URI.parse(@base_url)
	    req = Net::HTTP::Get.new(@base_url)
	    req.basic_auth @cid, @cpw
	    response = Net::HTTP.start(url.host, url.port,:use_ssl => url.scheme == 'https') do |http|
				http.request(req) 
			end
	    data = JSON.parse(response.body)["d"]["results"]
			data.inject([]){|a,x| a << x["MediaUrl"] }
    end   
  end
  
  class Convert
    def initialize(img_path,opts={})
      @opts = {
        :outfile => img_path,#Tempfile.new("quote_image").path, 
        :size => UWord::IMAGE_WIDTH
      }.update(opts)
      @img = MiniMagick::Image.open(img_path)
    end
    
    # 水印，暂时不用
    def add_watermark(img)
      unless File.exist?("public/water_mark.png")
        opts = {
          :font => "public/font/Tallys/Tallys.ttf",
          :word_path => "public/water_mark.png"
        }
        Convert.draw_word(opts)
      end
      return img.composite(MiniMagick::Image.open("public/water_mark.png")) do |c|
        c.gravity "NorthWest"
      end
    end
    
    def self.draw_word(opts = {})
      opts = {
        :text => $config[:name],
        :font_size => 36,
        :type => 1,
        :word_path => "public/w.png",
        :font => "public/font/Lobster/Lobster.ttf"
      }.update(opts)
      case opts[:type]
      when 1
      `montage -background none -fill white -font '#{opts[:font]}' \
                 -pointsize #{opts[:font_size]} label:'#{opts[:text]}' +set label \
                 -shadow  xc:transparent -geometry +5+5 \
                 #{opts[:word_path]}`
      when 2
        `convert -size 280x50 xc:transparent -font '#{opts[:font]}' -pointsize #{opts[:font_size]} \
                   -fill black        -annotate +12+32 '#{opts[:text]}' \
                   -fill white       -annotate +13+33 '#{opts[:text]}' \
                   -fill transparent  -annotate +12.5+32.5 '#{opts[:text]}' \
                  -trim #{opts[:word_path]}`
                   
      end
    end

    def self.geo(src)
      img = MiniMagick::Image.open(src)
      return img["width"],img["height"]
    end

    def self.square_thumb(src,thumb_size)
      img = MiniMagick::Image.open(src)
      img.combine_options do |c|
        c.auto_orient
        c.thumbnail "x#{thumb_size*2}"
        c.resize "#{thumb_size*2}x<"
        c.resize "50%"
        c.gravity "center"
        c.crop "#{thumb_size}x#{thumb_size}+0+0"
        c.quality 92
      end
      img
    end
    
		# 合成单张
    def draw(word_path,opt = {})
      # 先缩小尺寸
      @img.resize @opts[:size].to_s
      # 再裁剪
      @img.crop "280x400+0+0"
      if opt[:original]
        @img.write opt[:original]
      end
      result = @img.composite(MiniMagick::Image.open(word_path)) do |c|
        c.gravity "center"
      end
      result.write(@opts[:outfile])
      `chmod 777 #{@opts[:outfile]}`
      return @img["height"]
    end

		# 多张合成gif
		def make_gif(path)
			
		end
    
  end
  
end
