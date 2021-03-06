# coding: utf-8
module Onion
	# 查单词
	class Word
		require 'wordnet'

		def initialize(word)
			word = word.strip
			unless @word = ::Word.where(:title => word).first
				@word = ::Word.new(:title => word)
			end
		end

		def init_c_page(title)
			c_url = $dict_source[:english] + title
			Mechanize.new{ |agent| agent.user_agent_alias = "Mac Safari"}.get(c_url)
		end

		def init_e_page(title)
			e_url = "http://www.vocabulary.com/dictionary/" + title
			Mechanize.new{ |agent| agent.user_agent_alias = "Mac Safari"}.get(e_url)
		end

		def get_content(e_page)
			e_page.search("//div[@id='definition']//p[@class='short']").text.strip
		end

		def get_cn_raw(c_page)
			page_sections = c_page.search("//div[@class='group_pos']")[0].css("p")
			page_sections.inject([]) do |n,m|
				pos = m.css(".fl").text.strip.gsub(".","")
				text = m.css(".label_list").text.strip.gsub(/\s/,'')
				n << {
					pos: pos,
					text: text
				}
			end
		end

		def get_en_raw(e_page)
			page_sections = e_page.search("//h3[@class='definition']")
			page_sections.inject([]) do |n,m|
				pos = m.css("a.anchor").text.strip
				text = m.text.gsub(/(\r|\n|\t)/,'').sub(pos,"").strip
				n << {
					pos: pos,
					text: text
				}
			end
		end

		def get_family(e_page)
			raw_family =  eval e_page.at("wordfamily").attr("data").gsub(":","=>")
			raw_family.map{|x| {:word => x["word"],:freq => x["freq"]} }
		end

		def from_web(title)
			c_page = init_c_page(title)
			e_page = init_e_page(title)

			cn = get_cn_raw(c_page) rescue []
			en = get_en_raw(e_page) rescue []

			content = get_content(e_page) rescue ""

			family = get_family(e_page) rescue []

			pos = cn.map{|x| x[:pos]} + en.map{|x| x[:pos]}

			{
				content: content,
				pos: pos.uniq,
				family: family,
				raw_content: {
					cn: cn,
					en: en
				}
			}
		end

		def insert(opts = {})
			unless opts[:skip_exist] && @word.content
				@word.attributes = from_web(@word.title)
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

		# words: Array
		def self.insert_collection(words,opts = {})
			cnt = 0
			words.each do |w|
				if word = ::Word.where(:title => w).first
					p "#{w} exist"
				else
					word = Word.new(w).insert
					cnt += 1
				end
				if opts[:tag]
					unless word.synset.include?(opts[:tag])
						word.synset << opts[:tag]
						word.save
						p "--"
					end
				end
			end
			cnt
		end

		def website
			url = "http://www.starbucks.com/site-map"
			page = Mechanize.new{ |agent| agent.user_agent_alias = "Mac Safari"}.get(url)
			columns = page.search("//div[@class='subsection']")[0].css(".column")
			x = columns[0].css("li a").map{|x| x.attr("href")} + columns[1].css("li a").map{|x| x.attr("href")}
			ws = x.inject([]){|a,b| a << b.split("/") }.flatten.uniq
			ws.inject([]){|a,b| a << b.split("-") }.flatten.uniq
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
