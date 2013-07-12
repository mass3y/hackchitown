require 'rho/rhocontroller'
require 'helpers/browser_helper'
require 'json'

class ServiceController < Rho::RhoController
  include BrowserHelper

  # GET /Service
  def index
    @services = Service.find(:all)
    redirect :action => :getServicesList  unless @services.size > 0    
    render :back => '/app'
  end

  # GET /Service/{1}
  def show
    @service = Service.find(@params['id'])
    if @service
      render :action => :show, :back => url_for(:action => :index)
    else
      redirect :action => :index
    end
  end

  # GET /Service/new
  def new
    @service = Service.new
    render :action => :new, :back => url_for(:action => :index)
  end

  # GET /Service/{1}/edit
  def edit
    @service = Service.find(@params['id'])
    if @service
      render :action => :edit, :back => url_for(:action => :index)
    else
      redirect :action => :index
    end
  end

  # POST /Service/create
  def create
    @service = Service.create(@params['service'])
    redirect :action => :index
  end

  # POST /Service/{1}/update
  def update
    @service = Service.find(@params['id'])
    @service.update_attributes(@params['service']) if @service
    redirect :action => :index
  end

  # POST /Service/{1}/delete
  def delete
    @service = Service.find(@params['id'])
    @service.destroy if @service
    redirect :action => :index  
  end

  def getServicesList
    Rho::AsyncHttp.get(
      :url => "#{$CHI311_SERVER_URL}/services.json", 
      # :url => "http://311api.cityofchicago.org/open311/v2/services.json",                                
      #:authorization => {:type => :basic, :username => 'user', :password => 'none'},
      # :callback => (url_for :action => :httpget_callback),
      :callback => url_for(:action => :getServicesList_callback),
      :callback_param => "" )

      @response['headers']['Wait-Page'] = 'true'
       render :action => :wait      
    end
   
   def getServicesList_callback
         if @params["status"] == "ok"
           app_info "received CHI311 services results"
             @@get_result = @params['body']
          # puts "Chi311 service list results: #{@@get_result}"
            parsed = Rho::JSON.parse(@@get_result)
          # puts "Chi311 service list parsed: #{parsed}"            
             begin
               #  require 'rexml/document'         
               #  doc = REXML::Document.new(@@get_result)
                 # puts "invoice doc : #{doc}"
                 Service.delete_all() #remove all old invoice search results
                 @count = 0
                     db = ::Rho::RHO.get_src_db('Service')
                     db.start_transaction
                     begin
                       
                       parsed.each do |item|
                         puts "new item #{item}"
                         puts "new service name #{item["service_name"]}"
                         puts "new service code #{item["service_code"]}"
                         
                               # Creates a new Model object and saves it
                             #  new_item = Service.create(item)
                                                         
                        # service_code,service_name,description,metadata,type,keywords,group                          
                         srvc = Service.new()
                         srvc.id = item["service_code"].to_s() unless item["service_code"].nil?
                         srvc.service_code = item["service_code"].to_s() unless item["service_code"].nil?                           
                         srvc.service_name = item["service_name"] unless item["service_name"].nil?                           
                         srvc.description = item["description"] unless item["description"].nil?                                                      
                         srvc.metadata = item["metadata"] unless item["metadata"].nil?                                                                                 
                         srvc.type = item["type"] unless item["type"].nil?                                                                                                            
                         srvc.keywords = item["keywords"] unless item["keywords"].nil?                                                                                                                                       
                         srvc.group = item["group"] unless item["group"].nil?                                                                                                                                                                  
                         srvc.save
                       end if parsed                          
                       db.commit 
                       
                    rescue  #exception during DB transaction
                      db.rollback
                    end    
                            
            rescue Exception => e
                 puts "Error: #{e}"
                 @@get_result = "Error: #{e}"
             end       
 
         else
           app_info "error in CHI311 services results"           
         end
     WebView.navigate( url_for(:action => :index))

   end      

   
  def getServiceRequestsForCode   
    redirect :model => ServiceRequest, :action => :fetchServiceRequestsForCode, :id => @params['id']      
  end  
       
       
end
