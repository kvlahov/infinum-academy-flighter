class Session < ActiveModelSerializers::Model
  attributes :token
  attributes :user
end
