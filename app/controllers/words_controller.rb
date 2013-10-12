class WordsController < ApplicationController
	before_filter :authenticate_member!

	# @course_id
	def index
		@course = Course.find(params[:_id])
		@teacher = @course.member
		data = @course.words.each_with_index.map do |w,i|
			ext = {
				image: w.image,
				num: i + 1
			}
			w.as_json.merge!(ext)
		end
		render_json 0,"ok",data
	end

	# word page
	def show
		@word = Word.find(params[:id])
		set_seo_meta(@word.title)
	end

	# u_word page
	def u_show
		@u_word = UWord.find(params[:id])
		set_seo_meta(@u_word.title)
	end

	# teacher view
	# 联想同义词，提供wordnet & bing参考
	# POST
	def fetch
		title = params[:title].strip
		word = Onion::Word.new(title).insert(skip_exist: 1)
		# 联想好友们的发音，图片
		unless word.synset.present?
			word.synset = Onion::Word.wordnet(title,:synset)
		end
		if word.sentence.blank?
			word.sentence = Onion::Word.from_bing(title).map{|x| x[:en]}
		end
		word.save
		render_json 0,"ok",word.as_json
	end

	# @id
	# @synset array
	# @sentence
	# 由老师编辑添加
	def add_imagine
		word = Word.find(params[:_id])
		word.synset = params[:synset].split(",")
		word.sentence = params[:sentence].split("~")
		word.save
		render_json 0,"ok",word.as_json
	end

end
