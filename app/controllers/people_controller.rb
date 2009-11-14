class PeopleController < ApplicationController
  #ActiveRecord::Base.include_root_in_json=false (be sure to put this in environment.rb)
  
  # GET /people
  # GET /people.json
  def index
    skey="id"
    skey=params[:sort].split(" ")[0].split(";")[0] if params[:sort]
    skey="id" if skey.length==0
    skey+=" ASC"
    c=nil
    c=ActiveSupport::JSON.decode(params[:clause]) if params[:clause]
    c={} if not c.is_a? Hash
    @people = Person.find(:all, :order=>skey, :conditions=>c)

    respond_to do |format|
      format.html # index.html.erb
      format.json  { render :json => @people }
    end
  end

  # GET /people/1
  # GET /people/1.json
  def show
    @person = Person.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json  { render :json => @person }
    end
  end

  # GET /people/new
  # GET /people/new.json
  def new
    @person = Person.new

    respond_to do |format|
      format.html # new.html.erb
      format.json  { render :json => @person }
    end
  end

  # GET /people/1/edit
  def edit
    @person = Person.find(params[:id])
  end

  # POST /people
  # POST /people.json
  def create
    @person = Person.new(params[:model])

    respond_to do |format|
      if @person.save
        flash[:notice] = 'Person was successfully created.'
        format.html { redirect_to(@person) }
        format.json  { render :json => @person, :status => :created, :location => @person }
      else
        format.html { render :action => "new" }
        format.json  { render :json => @person.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /people/1
  # PUT /people/1.json
  def update
    @person = Person.find(params[:id])

    respond_to do |format|
      if @person.update_attributes(params[:model])
        flash[:notice] = 'Person was successfully updated.'
        format.html { redirect_to(@person) }
        format.json  { render :json=>nil }
      else
        format.html { render :action => "edit" }
        format.json  { render :json => @person.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /people/1
  # DELETE /people/1.json
  def destroy
    @person = Person.find(params[:id])
    @person.destroy

    respond_to do |format|
      format.html { redirect_to(people_url) }
      format.json  { render :json=>true }
    end
  end
end
