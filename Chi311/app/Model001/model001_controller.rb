require 'rho/rhocontroller'
require 'helpers/browser_helper'

class Model001Controller < Rho::RhoController
  include BrowserHelper

  def asynchttp
    Rho::AsyncHttp.get(
      :url => "http://311api.cityofchicago.org/open311/v2/requests.json?service_code=4ffa4c69601827691b000018&status=open",
      #:headers => {"Cookie" => cookie},
      :callback => (url_for :action => :httpget_callback)
      #:callback_param => "" 
      )
      
    redirect :action => :viewhttp
  end
  
  def httpget_callback
    $httpresult = @params['body'][0]
      
    @params['body'].each do |service_request_id|
      myproduct = Model001.new
      myproduct.service_request_id = service_request_id["service_request_id"]
      myproduct.requested_datetime = service_request_id["requested_datetime"]
      myproduct.address = service_request_id["address"]
      myproduct.save  
    end  
      
    WebView.refresh($httpresult)   
  end
  
  # GET /Model001
  def index
    @model001s = Model001.find(:all)
    render :back => '/app'
  end

  # GET /Model001/{1}
  def show
    @model001 = Model001.find(@params['id'])
    if @model001
      render :action => :show, :back => url_for(:action => :index)
    else
      redirect :action => :index
    end
  end

  # GET /Model001/new
  def new
    @model001 = Model001.new
    render :action => :new, :back => url_for(:action => :index)
  end

  # GET /Model001/{1}/edit
  def edit
    @model001 = Model001.find(@params['id'])
    if @model001
      render :action => :edit, :back => url_for(:action => :index)
    else
      redirect :action => :index
    end
  end

  # POST /Model001/create
  def create
    @model001 = Model001.create(@params['model001'])
    redirect :action => :index
  end

  # POST /Model001/{1}/update
  def update
    @model001 = Model001.find(@params['id'])
    @model001.update_attributes(@params['model001']) if @model001
    redirect :action => :index
  end

  # POST /Model001/{1}/delete
  def delete
    @model001 = Model001.find(@params['id'])
    @model001.destroy if @model001
    redirect :action => :index  
  end
end
