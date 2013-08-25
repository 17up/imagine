class ChatController < WebsocketRails::BaseController
  # 独立的server,不能用current_member
	def initialize_session
      controller_store[:user_count] = 0
  end

	def client_connected
  	controller_store[:user_count] += 1
    #send_message :enter, data
  end

  def delete_user
  	controller_store[:user_count] -= 1
    if connection_store.keys.length == 1
      channel = connection_store.keys[0]
      send_leave(channel,connection_store[channel])
    end
 	end

 	def new_message
    channel = message["cid"]
    WebsocketRails[channel].trigger 'success', message
 	end

  def new_record
    channel = message["cid"]
    member = Member.find(message["uid"])
    message["url"] = member.audio_url(message["ts"])
    WebsocketRails[channel].trigger 'new_record', message
  end

  def enter_channel
      channel = data["cid"]
      mids = connection_store.collect_all(channel).compact
      if mids.length < 5
        guys = Member.where(:_id.in => mids)
        connection_store[channel] = data["uid"]
        newer = Member.find(data["uid"]).as_profile
        data = {
          guys: guys.collect{|x| x.as_profile},
          newer: newer
        }

        WebsocketRails[channel].trigger 'enter', data
      else
        WebsocketRails[channel].trigger 'enter_fail'
      end 
  end

  def leave_channel
      send_leave(data["cid"],data["uid"])
  end

  private
  def send_leave(channel,uid)
    connection_store[channel] = nil
    leaver = Member.find(uid).as_profile
    WebsocketRails[channel].trigger 'leave', leaver
  end
end
