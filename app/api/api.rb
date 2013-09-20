class API < Grape::API
  mount Iquote
  mount Common
  mount Icard
end
