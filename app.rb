require 'rubygems'
require 'sinatra'
require "sinatra/reloader"
require "json"
require "mysql2"


configure do
  set :views,         File.dirname(__FILE__) + '/views'
  set :public_folder, File.dirname(__FILE__) + '/public'
end

get '/' do
  @host = ENV['CF_INSTANCE_IP'] || "192.168.0.0"
  @port = ENV['CF_INSTANCE_PORT'] || "9292"
  @index = ENV['CF_INSTANCE_INDEX'] || "0"

  vcap_services = JSON.parse(ENV['VCAP_SERVICES'])
  db_user = vcap_services['cleardb'].first['credentials']['username']
  db_password = vcap_services['cleardb'].first['credentials']['password']
  db_host = vcap_services['cleardb'].first['credentials']['hostname']
  @db_name = vcap_services['cleardb'].first['credentials']['name']

  mysql_client = Mysql2::Client.new(host: db_host, username: db_user, password: db_password)
  @query_result = mysql_client.query("SELECT table_name FROM INFORMATION_SCHEMA.TABLES")

  erb :index
end
