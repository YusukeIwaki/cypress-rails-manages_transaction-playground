json.users @users do |user|
  json.id user.id
  json.name user.name
  json.created_at user.created_at.to_i
end
