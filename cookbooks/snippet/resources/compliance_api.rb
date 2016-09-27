include LearnChef::SnippetHelpers
include LearnChef::ComplianceHelpers
require 'net/http'

property :url, [ String, nil ], default: nil
property :data, [ Array, Hash, nil ], default: nil
property :key, [ String, nil ], default: nil
property :user, [ String, nil ], default: nil
property :overwrite, [ TrueClass, FalseClass ], default: false
property :insecure, [ TrueClass, FalseClass ], default: true
property :scheme, String, default: 'https'
property :accept_response, [ Integer, Array ], default: 200

def initialize(*args)
  super
  @url ||= snippet_options[:compliance_url]
  @user ||= snippet_options[:compliance_user]
end

action :login do
  # POST /api/login
  compliance_post(new_resource, 'login')

  # Returns:
  # eyJhbGciOiJSUzI1NiIsImtpZCI6InRySE ...abbreviated...
end

action :add_key do
  # POST /api/owners/USER/keys
  compliance_post(new_resource, "owners/#{user}/keys", access_token)

  # Returns:
  #{
  #  "id": "85f92d4c-f3c6-4173-72e1-0a7a68cbecde"
  #}
end

action :add_env do
  # POST /api/owners/USER/envs
  compliance_post(new_resource, "owners/#{user}/envs", access_token)

  # Returns:
  # {
  #   "id": "a1f16feb-d18e-4725-6462-8b296a709d73",
  #   "owner": "7ae9dd7d-5201-4ae3-4949-60eb4b902e77",
  #   "name": "Development",
  #   "lastScan": "0001-01-01T00:00:00Z",
  #   "complianceStatus": 0,
  #   "patchlevelStatus": 0,
  #   "unknownStatus": 0
  # }
end

action :add_node do
  # POST /api/owners/USER/nodes
  compliance_post(new_resource, "owners/#{user}/nodes", access_token)

  # Returns:
  # [
  #  "d850ba44-7a82-4177-50db-79be1143d632",
  #  "33ecfce5-f781-4eb7-6828-beb090ffe9b5"
  # ]
end

action :check_connectivity do
  # GET /api/owners/USER/envs/ENV/nodes/NODE_ID/connectivity
  data = new_resource.data
  compliance_get(new_resource, "owners/#{data['user']}/envs/#{data['env']}/nodes/#{data['node_id']}/connectivity", access_token)

  # Returns:
  # {"arch"=>"x86_64", "family"=>"redhat", "release"=>"7.2.1511"}
end

action :scan_node do
  # POST /api/owners/USER/scans
  compliance_post(new_resource, "owners/#{user}/scans", access_token)

  # Returns:
  # {
  #   "id": "57130678-1a1f-405d-70bf-fe570a25621e"
  # }
end

def compliance_get(new_resource, path, headers = {})
  url = new_resource.url
  key = new_resource.key
  scheme = new_resource.scheme
  insecure = new_resource.insecure
  accept_response = [new_resource.accept_response].flatten

  url = URI.parse("#{scheme}://#{url}/api/#{path}")
  req = Net::HTTP::Get.new(url.path)
  req['Content-Type'] = 'application/json'
  headers.each_pair do |key, value|
    req[key] = value
  end
  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = (url.scheme == "https")
  http.verify_mode = insecure ? OpenSSL::SSL::VERIFY_NONE : OpenSSL::SSL::VERIFY_PEER
  res = http.request(req)
  unless accept_response.any? { |c| res.code == c.to_s }
    raise "Received error code #{res.code} (#{res.class.name}). Details:\n#{res.body}"
  end
  # Response might be JSON, might be scalar.
  begin
    v = JSON.parse(res.body)
  rescue JSON::ParserError
    v = res.body
  end
  puts "Writing #{url.path} to key #{key}", 'data:', v
  set_compliance_data(key, v)
end

def compliance_post(new_resource, path, headers = {})
  return if !new_resource.overwrite && has_compliance_data?(new_resource.key)

  url = new_resource.url
  data = new_resource.data
  key = new_resource.key
  scheme = new_resource.scheme
  insecure = new_resource.insecure
  accept_response = [new_resource.accept_response].flatten

  url = URI.parse("#{scheme}://#{url}/api/#{path}")
  req = Net::HTTP::Post.new(url.path)
  req['Content-Type'] = 'application/json'
  headers.each_pair do |key, value|
    req[key] = value
  end
  req.body = (data || {}).to_json
  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = (url.scheme == "https")
  http.verify_mode = insecure ? OpenSSL::SSL::VERIFY_NONE : OpenSSL::SSL::VERIFY_PEER
  res = http.request(req)
  unless accept_response.any? { |c| res.code == c.to_s }
    raise "Received error code #{res.code} (#{res.class.name}). Details:\n#{res.body}"
  end
  # Response might be JSON, might be scalar.
  begin
    v = JSON.parse(res.body)
  rescue JSON::ParserError
    v = res.body
  end
  puts "Writing #{url.path} to key #{key}", 'data:', v
  set_compliance_data(key, v)
end

def access_token
  { "Authorization" => "Bearer #{get_compliance_data('access_token')}" }
end
