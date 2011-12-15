#!/usr/bin/env ruby

require 'rubygems'
require 'sinatra'
require 'json'

require 'nagios/status.rb'

STATUS_FILE = "status.dat"

get '/:host' do
  nagios = Nagios::Status.new
  
  begin
    nagios.parsestatus(STATUS_FILE)
  rescue
    [500, "Unable to parse service status! Contact support."]
  end
  
  begin
    services  = nagios.status["hosts"][params[:host]]["servicestatus"]
    service_statuses = Array.new
    services.each do |service|
     status_hash = {  :name    => service[1]["service_description"],
                      :state  => service[1]["current_state"],
                      :detail => service[1]["plugin_output"],
                      :timestamp => service[1]["last_check"] }
      service_statuses.push status_hash
    end
  
    return service_statuses.to_json
  rescue
    [404, "This host does not exist!"]
  end
  
end

get '/:host/:service/status' do
  nagios = Nagios::Status.new
  
  begin
    nagios.parsestatus(STATUS_FILE)
  rescue
    [500, "Unable to parse service status! Contact support."]
  end
  
  begin
    state  = nagios.status["hosts"][params[:host]]["servicestatus"][params[:service]]["current_state"] 
    detail = nagios.status["hosts"][params[:host]]["servicestatus"][params[:service]]["plugin_output"]
    timestamp = nagios.status["hosts"][params[:host]]["servicestatus"][params[:service]]["last_check"]
  
    statusobject = {:service => params[:service], :state => state, :timestamp => timestamp, :detail => detail}
  
    return statusobject.to_json
  rescue
    [404, "This service does not exist!"]
  end
  
end


def fetch_nagios_data
end