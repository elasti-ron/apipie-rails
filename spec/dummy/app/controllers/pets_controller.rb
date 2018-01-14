class PetsController < ApplicationController

  def_param_group :pet do
    property :pet_inner_hash, Hash do
      property :name, String, :desc => "Name of pet", :required => false
      property :animal, String, :desc => "Type of pet"
      property :weight, Integer, :desc => "Weight in pounds"
      param :nickname, String, :only_in => :response
    end
  end

  def_param_group :super_pet do
    property :super_pet_inner_hash, Hash do
      param_group :pet
      # param :superpower, String, :desc => "The pet's superpower", :required => true
    end
  end

  # def_param_group :super_pet2 do
  #   param :pet, Hash do
  #     param :name, String, :desc => "Name of pet", :required => true
  #     param :animal, String, :desc => "Type of pet", :required => true
  #   end
  #   param :superpower, String, :desc => "The pet's superpower", :required => true
  # end

  api :POST, "/pets", "Create a pet"
  returns :super_pet, :code => 201
  def create_pet
    render :plain => "OK #{params.inspect}"
  end

  api :POST, "/pets2", "Create a pet"
  # returns :pet
  # param :int1, Integer
  # param_group :super_pet
  returns :code => 201, :desc => "Found a super pet" do
    param_group :super_pet
  end
  returns :code => 202 do
    param_group :pet
  end
  returns :code => 203 do
    param_group :super_pet
    param_group :pet
  end
  returns :code => 204 do
    property :code1, Integer, :desc => "Integer"
    property :code2, ["hi", "bye"], :desc => "Enum"
  end
  def create_pet
    render :plain => "OK #{params.inspect}"
  end



  # api :GET, "/pets", "Get all pets"
  # returns :array_of => :pet, :desc => "list of users"
  # def index
  #   redner :plain => "OK #{params.inspect}"
  # end
end

