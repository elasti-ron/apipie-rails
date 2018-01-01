class PetsController < ApplicationController

  def_param_group :pet do
    # param :pet, Hash do
      param :name, String, :desc => "Name of pet", :required => true
      param :animal, String, :desc => "Type of pet", :required => true
    # end
  end

  def_param_group :super_pet do
    param :pet, Hash do
      param :name, String, :desc => "Name of pet", :required => true
      param :animal, String, :desc => "Type of pet", :required => true
    end
    param :superpower, String, :desc => "The pet's superpower", :required => true
  end

  api :POST, "/pets", "Create a pet"
  param_group :pet
  returns :pet
  returns 201, :super_pet
  def create
    render :plain => "OK #{params.inspect}"
  end

  # api :GET, "/pets", "Get all pets"
  # returns :array_of => :pet, :desc => "list of users"
  # def index
  #   redner :plain => "OK #{params.inspect}"
  # end
end

