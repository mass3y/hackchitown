require 'rho/rhocontroller'
require 'helpers/browser_helper'

class ServiceRequestController < Rho::RhoController
  include BrowserHelper

  # GET /ServiceRequest
  def index
    @servicerequests = ServiceRequest.find(:all)
    render :back => '/app'
  end

  # GET /ServiceRequest/{1}
  def show
    @servicerequest = ServiceRequest.find(@params['id'])
    if @servicerequest
      render :action => :show, :back => url_for(:action => :index)
    else
      redirect :action => :index
    end
  end

  # GET /ServiceRequest/new
  def new
    @servicerequest = ServiceRequest.new
    render :action => :new, :back => url_for(:action => :index)
  end

  # GET /ServiceRequest/{1}/edit
  def edit
    @servicerequest = ServiceRequest.find(@params['id'])
    if @servicerequest
      render :action => :edit, :back => url_for(:action => :index)
    else
      redirect :action => :index
    end
  end

  # POST /ServiceRequest/create
  def create
    @servicerequest = ServiceRequest.create(@params['servicerequest'])
    redirect :action => :index
  end

  # POST /ServiceRequest/{1}/update
  def update
    @servicerequest = ServiceRequest.find(@params['id'])
    @servicerequest.update_attributes(@params['servicerequest']) if @servicerequest
    redirect :action => :index
  end

  # POST /ServiceRequest/{1}/delete
  def delete
    @servicerequest = ServiceRequest.find(@params['id'])
    @servicerequest.destroy if @servicerequest
    redirect :action => :index  
  end
  

  def fetchServiceRequestsForCode

     srvc_code = "service_code=#{@params['id']}"
#    srvc_code = "service_code=4ffa4c69601827691b000018"
#    http://311api.cityofchicago.org/open311/v2/requests.json?service_code=4ffa4c69601827691b000018  
    srvc_code = srvc_code.sub("{","").sub("}","")    
    puts "in service request call.  srvc_code = #{srvc_code}"
    Rho::AsyncHttp.get(
      #  :url => "#{$CHI311_SERVER_URL}/requests.json?service_code=#{$srvc_code.to_s()}",
        :url => "http://311api.cityofchicago.org/open311/v2/requests.json?#{srvc_code}",
        #:authorization => {:type => :basic, :username => 'user', :password => 'none'},
        # :callback => (url_for :action => :httpget_callback),
        :callback => url_for(:action => :getServiceRequestsForCode_callback),
        :callback_param => "" )
   #      @response["headers"]["Wait-Page"] = "true"
         render :action => :wait          
  end
  
  def getServiceRequestsForCode_callback
          if @params["status"] == "ok"
            app_info "received service request results"
              @@get_result = @params['body']
           puts "service request results: #{@@get_result}"
             parsed = Rho::JSON.parse(@@get_result)
           # puts "Chi311 service list parsed: #{parsed}"            
              begin
                  #require 'rexml/document'         
                  # doc = REXML::Document.new(@@get_result)
                  # puts "invoice doc : #{doc}"
                  ServiceRequest.delete_all() #remove all old invoice search results
                  @count = 0
                      db = ::Rho::RHO.get_src_db('ServiceRequest')
                      db.start_transaction
                      begin
                        
                        parsed.each do |item|
                          puts "new item #{item}"
                          puts "new service name #{item["service_name"]}"
                          puts "new service code #{item["service_code"]}"
                          
                                # Creates a new Model object and saves it
                               new_item = ServiceRequest.create(item)
                                                          
#                         # service_code,service_name,description,metadata,type,keywords,group                          
#                          srvc = Service.new()
#                          srvc.id = item["service_code"].to_s() unless item["service_code"].nil?
#                          srvc.service_code = item["service_code"].to_s() unless item["service_code"].nil?                           
#                          srvc.service_name = item["service_name"] unless item["service_name"].nil?                           
#                          srvc.description = item["description"] unless item["description"].nil?                                                      
#                          srvc.metadata = item["metadata"] unless item["metadata"].nil?                                                                                 
#                          srvc.type = item["type"] unless item["type"].nil?                                                                                                            
#                          srvc.keywords = item["keywords"] unless item["keywords"].nil?                                                                                                                                       
#                          srvc.group = item["group"] unless item["group"].nil?                                                                                                                                                                  
#                          srvc.save
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
            app_info "error in CHI311 service request results"           
            # In this example, an error just navigates back to the index w/o transition.
             #url_for( :action => :search)   #noel, for some reason this looses style when sent back to same page 
          end
      WebView.navigate( url_for(:action => :index))
 
    end      
  
  
  
end
