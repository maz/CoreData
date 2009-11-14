class <%= plural_class_name %>Controller < ApplicationController
  #ActiveRecord::Base.include_root_in_json=false (be sure to put this in environment.rb)
  
  # GET /<%= plural_model_name %>
  # GET /<%= plural_model_name %>.json
  def index
    skey="id"
    skey=params[:sort].split(" ")[0].split(";")[0] if params[:sort]
    skey="id" if skey.length==0
    skey+=" ASC"
    c=nil
    c=ActiveSupport::JSON.decode(params[:clause]) if params[:clause]
    c={} if not c.is_a? Hash
    @<%= plural_model_name %> = <%= upcase_model_name %>.find(:all, :order=>skey, :conditions=>c)

    respond_to do |format|
      format.json  { render :json => @<%= plural_model_name %> }
    end
  end

  # GET /<%= plural_model_name %>/1
  # GET /<%= plural_model_name %>/1.json
  def show
    @<%= model_name %> = <%= upcase_model_name %>.find(params[:id])

    respond_to do |format|
      format.json  { render :json => @<%= model_name %> }
    end
  end

  # POST /<%= plural_model_name %>
  # POST /<%= plural_model_name %>.json
  def create
    @<%= model_name %> = <%= upcase_model_name %>.new(params[:model])

    respond_to do |format|
      if @<%= model_name %>.save
        format.json  { render :json => @<%= model_name %>, :status => :created}
      else
        format.json  { render :json => @<%= model_name %>.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /<%= plural_model_name %>/1
  # PUT /<%= plural_model_name %>/1.json
  def update
    @<%= model_name %> = <%= upcase_model_name %>.find(params[:id])

    respond_to do |format|
      if @<%= model_name %>.update_attributes(params[:model])
        flash[:notice] = '<%= upcase_model_name %> was successfully updated.'
        format.json  { render :json=>nil }
      else
        format.json  { render :json => @<%= model_name %>.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /<%= plural_model_name %>/1
  # DELETE /<%= plural_model_name %>/1.json
  def destroy
    @<%= model_name %> = <%= upcase_model_name %>.find(params[:id])
    @<%= model_name %>.destroy

    respond_to do |format|
      format.json  { render :json=>true }
    end
  end
end
