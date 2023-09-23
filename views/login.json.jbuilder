json.success true
json.user do
  json.name @user.name
  json.access_token do
    json.token @api_access_token.token
    json.expires_at @api_access_token.expires_at.to_i
  end
end
