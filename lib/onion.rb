# coding: utf-8 
module Onion
  # 查单词
  class Word  
    require 'wordnet'

    def initialize(word)
      unless @word = ::Word.where(:title => word).first
      	@word = ::Word.new(:title => word) 
      end    
    end

    def from_web(title)
      c_url = $dict_source[:english] + title
      e_url = "http://www.vocabulary.com/dictionary/" + title

      c_page = Mechanize.new.get(c_url)
      e_page = Mechanize.new.get(e_url)

      content = {
        "zh-cn" => c_page.parser.xpath("//div[@class='group_pos']").text.gsub(/\s/,"").strip,
        "en" => e_page.parser.xpath("//div[@id='definition']//p[@class='short']").text
      }
    end
  
    def insert(opts = {})
      unless opts[:skip_exist] && @word.content
        @word.content_translations = from_web(@word.title)  
        @word.save     
      end 
      @word 
    end  

    def self.wordnet(title,sense = :word,rel = nil)
      lex = WordNet::Lexicon.new
      word = lex[title,rel]
      case sense
      when :word
        word
      when :sample
        word.samples()
      when :synset
        lex.lookup_synsets(title).map{|x| x.words.map(&:lemma)}.flatten.uniq
      when :hypernyms #上义
        word.hypernyms
      when :hyponyms #下义
        word.hyponyms
      end
    end

    def self.from_tweet(title,count = 1)
      result = Wali::Base.new(Authorization.official("twitter")).client.search(title,:result_type => "popular",:count => count,:show_user => false,:include_entities => false)
      sentences = result.statuses.collect(&:text).select{|s| !s.scan(/#|RT|&amp/).any? }
      sentences.map{|x| x.gsub(/\(\d+\)|~|http([^\s]*)(\s|$)/,'')}.uniq if sentences.any?
    end

    def self.from_bing(title)
      url = "http://cn.bing.com/dict/search?q=#{title}"
      client = Mechanize.new{ |agent|
          agent.user_agent_alias = "Mac Safari" #"Windows Mozilla" 
      } 
      client.get(url) do |page|
        return (page/'div.se_li1').map{|x| 
          {
            en: x.at(".sen_en").text,
            cn: x.at(".sen_cn").text
          }
        }
      end
    end

    # insert words form file
    def self.form_file
      # page = Nokogiri::HTML(open(Rails.root.join('public','v.html')))
      # words = page.css("li.entry").inject([]) do |a,x|
      # 	a << x.attr("word")
      # end.uniq

      # words.each do |w|
      # 	if ::Word.where(:title => w).any?
      # 		p "#{w} exist"
      # 	else
      # 		Word.new(w).insert
      # 		p "new #{w}"
      # 	end
      # end
    end 
  end

  class Paragraph

  end
  
  class Quote
    require 'goodreads'
    include Utils::Service
    # tag : inspirational
    # author : 947.William_Shakespeare
    # author_id : 947
    def initialize(opt={})
      if opt[:author]       
        @info = "/author/quotes/" + opt[:author]
      elsif opt[:tag]
        @info = "/quotes/tag/" + opt[:tag]
      elsif opt[:work]
        @info = "/work/quotes/" + opt[:work]
      else
        @info = "/quotes"
      end
      @url = ::Quote::BASE_URL + @info
      @count = ::Quote.count
    end
    
    def fetch
      frame = Nokogiri::HTML(open(@url),nil,'utf-8')
      if frame
        frame.css(".quoteDetails").each do |x| 
          quote = ::Quote.new
          _text = x.css(".quoteText")[0]
          unless _text.css("i a").blank? 
            source_name = _text.css("i a")[0].text 
            source_link = _text.css("i a")[0]["href"]
            quote.source = {:name => source_name,:link => source_link}
          end      
          unless _text.css("a").blank?
            author_name = _text.css("a")[0].text
            author_link = _text.css("a")[0]["href"]
            quote.author = {:name => author_name,:link => author_link}
          end
          #_text.content.scan(/“(.+)”/).map{$1}[0]
          #.scan(/&ldquo;(.+)&rdquo;/).map{$1}[0]
          quote.content = _text.to_html(:encoding => 'UTF-8').scan(/“(.+)”/).map{$1}[0]
  
          if _foot = x.css(".quoteFooter .left")[0]
            tags = _foot.css("a").inject([]) do |a,e|
              a << e.text
            end
            quote.tags = tags
          end
          # filter quotes without tags         
          quote.save
        end

        "#{::Quote.count - @count} new quotes"
      else
        "error: page not found"
      end
    end

    def get_author(name)
      key = load_service['goodreads']['app_key']
      secret = load_service['goodreads']['app_secret']
      client = Goodreads::Client.new(:api_key => key, :api_secret => secret)
      author = client.author_by_name(name)
      author.id
    end
  end
end