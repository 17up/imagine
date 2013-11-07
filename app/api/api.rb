class API < Grape::API
  mount Iquote
  mount Icard
end
