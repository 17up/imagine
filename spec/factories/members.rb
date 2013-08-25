# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :member do
  	sequence(:email){|n| "veggie#{n}@17up.org"}
  	password 'rccrcc17'
    password_confirmation 'rccrcc17'
	role 'u'
	sequence(:uid){|n| "veggie#{n}" }
  end

  factory :admin, :parent => :member do
    role 'a'
  end
end
