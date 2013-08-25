class InvitesController < ApplicationController

	# 邀请详情页面
	# invite_id
	def show
		@invite = Invite.find(params[:id])
		@course = Course.find(@invite.course_id)
		@member = @invite.member
		set_seo_meta(@course[:title],t('keywords'),t('describe'))
		session[:invite] = params[:id]
	end

end