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

end
