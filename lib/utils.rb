# -*- coding: utf-8 -*-
module Utils

  class << self

    def rand_passwd(size=6, opts = {})
      # 全部使用数字
      if opts[:number] == true
        alpha = (0..9).to_a
      elsif opts[:alpht] == true
        alpha = ('a'..'z').to_a
      else
        alpha = (0..9).to_a+('a'..'z').to_a+('A'..'Z').to_a
      end
      alpha.sample(size).join
    end

  end

  module Service

    def load_service
      YAML.load_file(Rails.root.join("config", "service.yml")).fetch(Rails.env)
    end
     
    def parse_ip(ip,opts={})
      if opts[:taobao]
        api_url = "http://ip.taobao.com/service/getIpInfo.php?ip="
        resp = HTTParty.get(api_url+ip).body
  		  data = JSON.parse(resp)
  		  if data["code"] == 0
  			  return data["data"]["country"] + data["data"]["region"] + data["data"]["city"] + data["data"]["isp"]
  		  end
  		else
  		  api_url = "https://api.weibo.com/2/location/geo/ip_to_geo.json"
        result = Curl.get(api_url,{:source => "83541187",:ip => ip})
        data = JSON.parse(result)["geos"][0]
        if opts[:geo]
          return data["latitude"],data["longitude"]
        else
          return data["more"]
        end
      end
    end
    
    # forecast
    def check_weather(city="上海")
      api_url = "http://sou.qq.com/online/get_weather.php?callback=Weather&city="
      request_url = URI.encode(api_url+city)
      resp = HTTParty.get(request_url).body
  		data = JSON.parse(resp.scan(/Weather\((\S+)\)/).flatten[0])
  		if data["real"]
  		  data["future"]["name"] + data["future"]["wea_0"] + data["real"]["temperature"] 
  	  end
    end

    # geo google
    # google map place search by text,get lat&lng
    def location(query)
      query = URI.encode query
      key = load_service["google"]["api_key"]
      request_url = "https://maps.googleapis.com/maps/api/place/textsearch/json?query=#{query}&key=#{key}&sensor=true"
      url = URI.parse(request_url)
      response = Net::HTTP.start(url.host, url.port,:use_ssl => url.scheme == 'https') do |http|
        http.request(Net::HTTP::Get.new(request_url)) 
      end
      data = JSON.parse(response.body)["results"][0]
      {
        :address => data["formatted_address"],
        :lat => data["geometry"]["location"]["lat"],
        :lng => data["geometry"]["location"]["lng"]
      }
    end

  end
  
  module Curl
    def self.get(url, data={})
      params = data.nil? ? "" : "?".concat( data.collect{ |k,v| "#{k}=#{CGI::escape(v.to_s)}" }.join('&') )
      
      uri = URI(url+params).to_s
      `curl '#{uri}' 2>/dev/null`
    end
    
    def self.post(url,data={})
      form = data.map{|k,v| "-F #{k}=#{v}"}.join(" ")
      `curl #{form} '#{url}' 2>/dev/null`
    end
  end
  
  module Cloud
    class Base
      def initialize(login={})
      	login = {
  				:name => "heartme.hero@gmail.com",
  				:passwd => ""
  			}.update(login)
  			@session = GoogleDrive.login(login[:name], login[:passwd])
  		end

  		def list
  			@session.files.inject([]){|a,x| a << x.title}
  		end

  		def upload(file_path,file_name)
  			@session.upload_from_file(file_path, file_name, :convert => false)
  		end

  		def download(file_name,save_path)
  			file = @session.file_by_title(file_name)
  			if file
  				file.download_to_file(save_path)
  			end
  		end
  		
    end
    
    class Backup < Base
      def word_image
        folder = "public/system/images/word"
      end
      
    end
    
  end 
  
end
