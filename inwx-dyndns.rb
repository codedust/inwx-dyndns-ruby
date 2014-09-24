#!/usr/bin/env ruby
require "./inwx/Domrobot"
require "yaml"
require "open-uri"
require "logger"

##### CONFIG #####

domain         = "example.com"      # the domain to be updated - e.g. "example.com", but NOT "www.example.com"
record_name    = "dyn.example.com"  # the record to be updated - e.g. "dyn.example.com" or "example.com" itself
user           = "username"
pass           = "password"
#domrobot_addr  = "api.ote.domrobot.com" # test environment
domrobot_addr  = "api.domrobot.com"      # production environment
ip_resolver    = "http://ifconfig.me/ip"
logfile        = "inwx-dyndns.log"       # path to logfile

##### ###### #####

logger = Logger.new(logfile, 10, 1024000)


### GET CURRENT IP ADDRESS

new_ip = open(ip_resolver) { |ip| ip.first }
puts "\nCURRENT IP: #{new_ip}"


### LOGIN

domrobot = INWX::Domrobot.new(domrobot_addr)
result = domrobot.login(user,pass)
puts "\nLOGIN RESULT", YAML::dump(result)

if result["code"] != 1000
  logger.warn "Authentication failed. Check username and password."
  abort "\nAuthentication failed. Check username and password."
end


### GET CURRENT DNS ENTRYS

object = "nameserver"
method = "info"
params = { :domain => domain }

result = domrobot.call(object, method, params)
puts "\nNAMESERVER INFO",YAML::dump(result)

if result["resData"].nil?
  logger.warn "The domain was not found. Check the `domain` variable in the CONFIG section."
  abort "\nThe domain was not found. Check the `domain` variable in the CONFIG section."
else
  record_index = result["resData"]["record"].index{|h| h["name"] == record_name }
  if record_index.nil?
    logger.warn "The DNS record was not found. Check the `record_name` variable in the CONFIG section."
    abort "\nThe DNS record was not found. Check the `record_name` variable in the CONFIG section."
  else
    record_id	   = result["resData"]["record"][record_index]["id"]
    record_content = result["resData"]["record"][record_index]["content"]
  end
end


### UPDATE ENTRY

if record_content != new_ip
  logger.info "Updating DNS entry to new IP #{new_ip}"
  puts "\nUpdating DNS entry to new IP #{new_ip}"

  object = "nameserver"
  method = "updateRecord"
  params = { :id => record_id, :content => new_ip, :ttl => 3600 }

  result = domrobot.call(object, method, params)
  puts "\nDNS RECORD UPDATE RESULT",YAML::dump(result)
  
  if result["code"] != 1000
    logger.error "Could not update DNS record."
    logger.debug YAML::dump(result)
    abort "\nCould not update DNS record."
  else
    logger.info "DNS update successful."
    puts "\nDNS update successful."
  end
else
  logger.info "IP has not changed yet (still #{record_content})"
  puts "\nIP has not changed yet (still #{record_content})"
end
