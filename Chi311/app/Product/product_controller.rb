require 'rho/rhocontroller'
require 'helpers/browser_helper'

class ProductController < Rho::RhoController
  include BrowserHelper

  def asynchttp
    Rho::AsyncHttp.get(
      :url => "http://www.google.com/",
      #:headers => {"Cookie" => cookie},
      :callback => (url_for :action => :httpget_callback),
      :callback_param => "" )
      
    redirect :action => :viewhttp
  end
  
  def httpget_callback
    $httpresult2 = @params['body']
    WebView.refresh($httpresult2)
    #WebView.navigate($httpresult2)   
  end
  
  # GET /Product
  def index
    @products = Product.find(:all)
    render :back => '/app'
  end

  # GET /Product/{1}
  def show
    @product = Product.find(@params['id'])
    if @product
      render :action => :show, :back => url_for(:action => :index)
    else
      redirect :action => :index
    end
  end

  # GET /Product/new
  def new
    @product = Product.new
    render :action => :new, :back => url_for(:action => :index)
  end

  # GET /Product/{1}/edit
  def edit
    @product = Product.find(@params['id'])
    if @product
      render :action => :edit, :back => url_for(:action => :index)
    else
      redirect :action => :index
    end
  end

  # POST /Product/create
  def create
    @product = Product.create(@params['product'])
    redirect :action => :index
  end

  # POST /Product/{1}/update
  def update
    @product = Product.find(@params['id'])
    @product.update_attributes(@params['product']) if @product
    redirect :action => :index
  end

  # POST /Product/{1}/delete
  def delete
    @product = Product.find(@params['id'])
    @product.destroy if @product
    redirect :action => :index  
  end
end
