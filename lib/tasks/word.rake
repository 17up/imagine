# coding: utf-8
namespace :word do

	desc "export words form Word DB to file"
	task :export => :environment do
		file = File.open(Rails.root.join('doc','words.txt'),"a")
		Word.all.each do |w|
			file.write w.title + "\n"
		end
		file.close
	end

	desc "renew sentence"
	task :sentence => :environment do
		Word.all.each do |w|
			w.sentence = Onion::Word.from_bing(w.title)
			w.save
		end
	end

	desc "renew content"
	task :content => :environment do
		Word.pluck(:title).each do |t|
			begin
				Onion::Word.new(t).insert
				p "------------------"
			rescue => ex
				p ex
				p t
			end
		end
	end

	desc "renew family"
	task  :family => :environment do
		Word.all.each do |w|
			begin
				e_url = "http://www.vocabulary.com/dictionary/" + w.title
				e_page = Mechanize.new{ |agent| agent.user_agent_alias = "Mac Safari"}.get(e_url)
				raw_family =  eval e_page.at("wordfamily").attr("data").gsub(":","=>")
				w.family = raw_family.map{|x| {:word => x["word"],:freq => x["freq"]} }
				w.save
				p "------------------"
			rescue => ex
				p ex
				p t
			end
		end
	end
end
