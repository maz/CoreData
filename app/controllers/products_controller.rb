class ProductsController < ApplicationController
  #ActiveRecord::Base.include_root_in_json=false (be sure to put this in environment.rb)
  before_filter :fetch_person
  
  # GET /products
  # GET /products.json
  def index
    skey="id"
    skey=params[:sort].split(" ")[0].split(";")[0] if params[:sort]
    skey="id" if skey.length==0
    skey+=" ASC"
    c=nil
    c=ActiveSupport::JSON.decode(params[:clause]) if params[:clause]
    c={} if not c.is_a? Hash
    @products = @person.products.find(:all, :order=>skey, :conditions=>c)

    respond_to do |format|
      format.json  { render :json => @products }
    end
  end

  # GET /products/1
  # GET /products/1.json
  def show
    @product = @person.products.find(params[:id])

    respond_to do |format|
      format.json  { render :json => @product }
    end
  end

  # POST /products
  # POST /products.json
  def create
    @product = @person.products.build(params[:model])

    respond_to do |format|
      if @product.save
        format.json  { render :json => @product, :status => :created}
      else
        format.json  { render :json => @product.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /products/1
  # PUT /products/1.json
  def update
    @product = @person.products.find(params[:id])

    respond_to do |format|
      if @product.update_attributes(params[:model])
        flash[:notice] = 'Product was successfully updated.'
        format.json  { render :json=>nil }
      else
        format.json  { render :json => @product.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1
  # DELETE /products/1.json
  def destroy
    @product = @person.products.find(params[:id])
    @product.destroy

    respond_to do |format|
      format.json  { render :json=>true }
    end
  end
  private
  def fetch_person
    @person=Person.find(params[:person_id])
  end
end
