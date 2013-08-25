class API < Grape::API
  mount Iquote
  mount Common
end