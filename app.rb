require 'rubygems'
require 'sinatra'
require "sinatra/reloader"
require "json"
require 'pg'


configure do
  set :views,         File.dirname(__FILE__) + '/views'
  set :public_folder, File.dirname(__FILE__) + '/public'
end

get '/' do
  @host = ENV['CF_INSTANCE_IP'] || "192.168.0.0"
  @port = ENV['CF_INSTANCE_PORT'] || "9292"
  @index = ENV['CF_INSTANCE_INDEX'] || "0"

  vcap_services = JSON.parse(ENV['VCAP_SERVICES'])
  service_name = ENV['SERVICE_NAME']
  url = vcap_services[service_name].first['credentials']['postgresuri']
  user = vcap_services[service_name].first['credentials']['POSTGRES_USER']
  password = vcap_services[service_name].first['credentials']['POSTGRES_PASSWORD']
  db_name = vcap_services[service_name].first['credentials']['POSTGRES_DB']
  pgUrl = URI.parse(url)
#  host = vcap_services[service_name].first['credentials']['POSTGRES_HOST']
#  port = vcap_services[service_name].first['credentials']['POSTGRES_PORT']

  conn = PGconn.connect( :host => pgUrl.host, :dbname => db_name, :port => 5432, :user => user, :password => password)
  @query_result = conn.exec('SELECT version()')[0]

  erb :index
end
