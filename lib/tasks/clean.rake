# coding: utf-8 
namespace :clean do
	desc "clean audio message"
  	task :audio_message => :environment do
  		`rm -rf #{Rails.root}/public/system/audios/member/`
  	end
end