ActionMailer::Base.smtp_settings = {
  :address              => "smtp.gmail.com",
  :enable_starttls_auto => true,
  :port                 => 587,
  :domain               => "17up.org", 
  :authentication       => :plain,
  :user_name            => "veggie.17up.org",
  :password             => "",
  :enable_starttls_auto => true
}