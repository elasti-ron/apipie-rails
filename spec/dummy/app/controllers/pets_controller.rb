class PetsController < ApplicationController

  #-----------------------------------------------------------
  # simple 'returns' example: a method that returns a pet record
  #-----------------------------------------------------------
  api :GET, "/pets/:id/as_properties", "Get a pet record"
  returns :code => 200 do
    property :name, String, :desc => "Name of pet", :required => false
    property :animal_type, ['dog','cat','iguana','kangaroo'], :desc => "Type of pet"   # required by default, because this is a 'property'
  end
  def show_as_properties
    render :plain => "showing pet properties"
  end

  #-----------------------------------------------------------
  # same example, but properties are defined in a param group
  #-----------------------------------------------------------
  def_param_group :pet do
    property :name, String, :desc => "Name of pet", :required => false
    property :animal_type, ['dog','cat','iguana','kangaroo'], :desc => "Type of pet"   # required by default, because this is a 'property'
  end

  api :GET, "/pets/:id/as_param_group_of_properties", "Get a pet record"
  returns :pet, :code => 200
  def show_as_param_group_of_properties
    render :plain => "showing pet properties defined as param groups"
  end


  #-----------------------------------------------------------
  # example with multiple param groups
  #-----------------------------------------------------------
  def_param_group :owner do   # a param group that can be used to describe inputs as well as outputs
    param :owner_name, String
  end
  def_param_group :user_response do # a param group that can be used to describe outputs only
    property :vote, [true,false]
  end

  api :GET, "/pets/by_owner_name/did_vote", "did any of the pets owned by the given user vote?"
  param_group :owner, :desc => "look up the user by name"
  returns :code => 200 do
    param_group :owner
    param_group :user_response
  end
  returns :code => 404  # no body
  def get_vote_by_owner_name
    render :plain => "no pets have voted"
  end


  #-----------------------------------------------------------
  # a method returning multiple codes,
  # some of which have a complex data structure
  #-----------------------------------------------------------
  def_param_group :pet_measurements do
    property :pet_measurements, Hash do
      property :weight, Integer, :desc => "Weight in pounds"
      property :height, Integer, :desc => "Height in inches"
      property :num_legs, Integer, :desc => "Number of legs", :required => false
    end
  end

  def_param_group :pet_history do
    property :did_visit_vet, [true,false], :desc => "Did the pet visit the veterinarian"
    property :avg_meals_per_day, Float, :desc => "Average number of meals per day"
  end

  api :GET, "/pets/:id/extra_info", "Get extra information about a pet"
  returns :code => 201, :desc => "Found a super pet" do
    param_group :pet
  end
  returns :code => 202 do
    param_group :pet
    param_group :pet_measurements
  end
  returns :code => 203 do
    param_group :pet
    param_group :pet_measurements
    property 'pet_history', Hash do  # the pet_history param_group does not contain a wrapping object,
                                     # so create one manually
      param_group :pet_history
    end
  end
  returns :code => 204, :desc => "in case fleas were discovered on the pet" do
    param_group :pet
    property :num_fleas, Integer, :desc => "Number of fleas on this pet"
  end
  def show_extra_info
    render :plain => "here's some extra info"
  end

  #-----------------------------------------------------------
  #  Not implemented yet - method returning an array
  #-----------------------------------------------------------

  # api :GET, "/pets", "Get all pets"
  # returns :array_of => :pet, :desc => "list of pets"
  # def index
  #   redner :plain => "pets"
  # end

end

