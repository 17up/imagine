class CoursesController < ApplicationController
	before_filter :authenticate_member!

	# 登記课程
	# 扣除 gem
	def checkin
		if @course = Course.find(params[:_id])
			if gems = current_member.checkin(@course)
				render_json 0,"ok",gems
			else
				render_json -2,"not enough gems"
			end
		else
			render_json -1,"no course"
		end
	end

	def update
		unless params[:_id].present? and find_member_course
			@course = current_member.courses.new
		end
		if @course.make_draft(params[:title],params[:tags],params[:content].strip)
			render_json 0,"save success",@course.as_json
		else
			render_json -1,"fail"
		end
	end

	def ready
		if find_member_course
			if @course.make_ready params[:raw_content]
				render_json 0,"wait for open"
			else
				render_json -2,"words limit 40"
			end
		else
			render_json -1,"no course"
		end
	end

	def open
		if find_member_course
			@course.make_open
			render_json 0,"open"
		else
			render_json -1,"no course"
		end
	end

	def destroy
		if find_member_course
			@course.destroy
			render_json 0,"destroy"
		else
			render_json -1,"no course"
		end
	end

	private
	def find_member_course
		if current_member.admin?
			@course = Course.find(params[:_id])
		else
			@course = current_member.courses.find(params[:_id])
		end
	end
end
