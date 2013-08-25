require 'spec_helper'

describe OliveController do
	login_admin

	describe "POST 'create_quote'" do
	    it "returns http success" do
	      	post 'create_quote'
	      	parsed_body = JSON.parse(response.body)
			parsed_body["status"].should == 0
	    end
	end

end
