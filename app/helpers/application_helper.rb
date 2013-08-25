module ApplicationHelper
	def file_upload_for(type)
		case type
		when "image"
			accept = 'image/png,image/gif,image/jpeg'
		when "mov"
			accept = "video/*"
    	when "audio"
      		accept = "audio/*"
		end
		file_field_tag type.to_sym,:accept => accept
	end

	def trc(str,len)
	    truncate(str,:length => len)
	end
end
