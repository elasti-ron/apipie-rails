require 'spec_helper'
require 'rack/utils'
require 'rspec/expectations'

RSpec::Matchers.define :have_param do |name, type, opts={}|
  def fail(msg)
    @fail_message = msg
    false
  end

  @fail_message = ""

  failure_message do |actual|
    @fail_message
  end

  match do |actual|
    return fail("expected schema to have type 'object' (got '#{actual[:type]}')") if (actual[:type]) != 'object'
    return fail("expected schema to include param named '#{name}' (got #{actual[:properties].keys})") if (prop = actual[:properties][name]).nil?
    return fail("expected param '#{name}' to have type '#{type}' (got '#{prop[:type]}')") if prop[:type] != type
    return fail("expected param '#{name}' to have description '#{opts[:description]}' (got '#{prop[:description]}')") if opts[:description] && prop[:description] != opts[:description]
    return fail("expected param '#{name}' to have enum '#{opts[:enum]}' (got #{prop[:enum]})") if opts[:enum] && prop[:enum] != opts[:enum]
    if !opts.include?(:required) || opts[:required] == true
      return fail("expected param '#{name}' to be required") unless actual[:required].include?(name)
    else
      return fail("expected param '#{name}' to be optional") if actual[:required].include?(name)
    end
    true
  end
end

describe PetsController do

  let(:desc) { Apipie.get_resource_description(PetsController, Apipie.configuration.default_version) }
  let(:swagger) {
    Apipie.configuration.swagger_suppress_warnings = true
    Apipie.to_swagger_json(Apipie.configuration.default_version, "pets")
  }

  def print_swagger
    puts JSON.generate(swagger)
  end

  def swagger_response_for(path, code=200, method='get')
    swagger[:paths][path][method][:responses][code]
  end

  describe "PetsController#index" do
    subject do
      desc._methods[:index]
    end

    it "should return code 200 with array of entries of the format {'pet_name', 'animal_type'}" do
      print_swagger
      returns_obj = subject.returns.detect{|e| e.code == 200 }

      puts returns_obj.to_json
      expect(returns_obj.code).to eq(200)
      expect(returns_obj.is_array?).to eq(true)

      expect(returns_obj).to match_param_structure([:pet_name, :animal_type])
    end

    it 'should have the response described in the swagger' do
      print_swagger
      response = swagger_response_for('/pets')
      expect(response[:description]).to eq("list of pets")

      schema = response[:schema]
      expect(schema[:type]).to eq("array")

      a_schema = schema[:items]
      expect(a_schema).to have_param(:pet_name, 'string', {:description => 'Name of pet', :required => false})
      expect(a_schema).to have_param(:animal_type, 'string', {:description => 'Type of pet', :enum => ['dog','cat','iguana','kangaroo']})
    end
  end

  describe "PetsController#show_as_properties" do
    subject do
      desc._methods[:show_as_properties]
    end

    it "should return code 200 with 'pet_name' and 'animal_type'" do
      returns_obj = subject.returns.detect{|e| e.code == 200 }

      puts returns_obj.to_json
      expect(returns_obj.code).to eq(200)
      expect(returns_obj.is_array?).to eq(false)

      expect(returns_obj).to match_param_structure([:pet_name, :animal_type])
    end

    it 'should have the response described in the swagger' do
      response = swagger_response_for('/pets/{id}/as_properties')
      expect(response[:description]).to eq("OK")

      schema = response[:schema]
      expect(schema).to have_param(:pet_name, 'string', {:description => 'Name of pet', :required => false})
      expect(schema).to have_param(:animal_type, 'string', {:description => 'Type of pet', :enum => ['dog','cat','iguana','kangaroo']})
    end
  end

  describe "PetsController#show_as_param_group_of_properties" do
    subject do
      desc._methods[:show_as_param_group_of_properties]
    end

    it "should return code 200 with 'pet_name' and 'animal_type'" do
      returns_obj = subject.returns.detect{|e| e.code == 200 }

      puts returns_obj.to_json
      expect(returns_obj.code).to eq(200)
      expect(returns_obj.is_array?).to eq(false)

      expect(returns_obj).to match_param_structure([:pet_name, :animal_type])
      expect(returns_obj.params_ordered[0].is_required?).to be_falsey
      expect(returns_obj.params_ordered[1].is_required?).to be_truthy
    end

    it 'should have the response described in the swagger' do
      response = swagger_response_for('/pets/{id}/as_param_group_of_properties')
      expect(response[:description]).to eq("The pet")

      schema = response[:schema]
      expect(schema).to have_param(:pet_name, 'string', {:description => 'Name of pet', :required => false})
      expect(schema).to have_param(:animal_type, 'string', {:description => 'Type of pet', :enum => ['dog','cat','iguana','kangaroo']})
    end
  end

  describe "PetsController#show_pet_by_id" do
    subject do
      desc._methods[:show_pet_by_id]
    end

    it "should have only oauth (from ApplicationController) and pet_id as an input parameters" do
      params_obj = subject.params_ordered

      expect(params_obj[0].name).to eq(:oauth)
      expect(params_obj[1].name).to eq(:pet_id)
    end

    it "should return code 200 with 'pet_id', pet_name' and 'animal_type'" do
      returns_obj = subject.returns.detect{|e| e.code == 200 }

      puts returns_obj.to_json
      expect(returns_obj.code).to eq(200)
      expect(returns_obj.is_array?).to eq(false)

      expect(returns_obj).to match_param_structure([:pet_id, :pet_name, :animal_type])
    end

    it 'should have the response described in the swagger' do
      response = swagger_response_for('/pets/pet_by_id')
      expect(response[:description]).to eq("OK")

      schema = response[:schema]
      expect(schema).to have_param(:pet_id, 'number', {:description => 'id of pet'})
      expect(schema).to have_param(:pet_name, 'string', {:description => 'Name of pet', :required => false})
      expect(schema).to have_param(:animal_type, 'string', {:description => 'Type of pet', :enum => ['dog','cat','iguana','kangaroo']})
    end
  end

  describe "PetsController#get_vote_by_owner_name" do
    subject do
      desc._methods[:get_vote_by_owner_name]
    end

    it "should return code 200 with 'owner_name' and 'vote'" do
      returns_obj = subject.returns.detect{|e| e.code == 200 }

      puts returns_obj.to_json
      expect(returns_obj.code).to eq(200)
      expect(returns_obj.is_array?).to eq(false)

      expect(returns_obj).to match_param_structure([:owner_name, :vote])
    end

    it 'should have the response described in the swagger' do
      response = swagger_response_for('/pets/by_owner_name/did_vote')
      expect(response[:description]).to eq("OK")

      schema = response[:schema]
      expect(schema).to have_param(:owner_name, 'string', {:required => false}) # optional because defined using 'param', not 'property'
      expect(schema).to have_param(:vote, 'boolean')
    end
  end

  describe "PetsController#show_extra_info" do
    subject do
      desc._methods[:show_extra_info]
    end

    it "should return code 201 with 'pet_name' and 'animal_type'" do
      returns_obj = subject.returns.detect{|e| e.code == 201 }

      puts returns_obj.to_json
      expect(returns_obj.code).to eq(201)
      expect(returns_obj.is_array?).to eq(false)

      expect(returns_obj).to match_param_structure([:pet_name, :animal_type])
    end
    it 'should have the 201 response described in the swagger' do
      response = swagger_response_for('/pets/{id}/extra_info', 201)
      expect(response[:description]).to eq("Found a pet")

      schema = response[:schema]
      expect(schema).to have_param(:pet_name, 'string', {:required => false})
      expect(schema).to have_param(:animal_type, 'string')
    end

    it "should return code 202 with spread out 'pet' and encapsulated 'pet_measurements'" do
      returns_obj = subject.returns.detect{|e| e.code == 202 }

      puts returns_obj.to_json
      expect(returns_obj.code).to eq(202)
      expect(returns_obj.is_array?).to eq(false)

      expect(returns_obj).to match_param_structure([:pet_name,
                                                    :animal_type,
                                                    {:pet_measurements => [:weight, :height, :num_legs]}
                                                   ])
    end
    it 'should have the 202 response described in the swagger' do
      response = swagger_response_for('/pets/{id}/extra_info', 202)
      expect(response[:description]).to eq('Accepted')

      schema = response[:schema]
      expect(schema).to have_param(:pet_name, 'string', {:required => false})
      expect(schema).to have_param(:animal_type, 'string')
      expect(schema).to have_param(:pet_measurements, 'object')

      pm_schema = schema[:properties][:pet_measurements]
      expect(pm_schema).to have_param(:weight, 'number', {:description => "Weight in pounds"})
      expect(pm_schema).to have_param(:height, 'number', {:description => "Height in inches"})
      expect(pm_schema).to have_param(:num_legs, 'number', {:description => "Number of legs", :required => false})
    end

    it "should return code 203 with spread out 'pet', encapsulated 'pet_measurements' and encapsulated 'pet_history'" do
      returns_obj = subject.returns.detect{|e| e.code == 203 }

      puts returns_obj.to_json
      expect(returns_obj.code).to eq(203)
      expect(returns_obj.is_array?).to eq(false)

      expect(returns_obj).to match_param_structure([:pet_name,
                                                    :animal_type,
                                                    {:pet_measurements => [:weight, :height,:num_legs]},
                                                    {:pet_history => [:did_visit_vet, :avg_meals_per_day]}
                                                   ])
    end
    it 'should have the 203 response described in the swagger' do
      response = swagger_response_for('/pets/{id}/extra_info', 203)
      expect(response[:description]).to eq('Non-Authoritative Information')

      schema = response[:schema]
      expect(schema).to have_param(:pet_name, 'string', {:required => false})
      expect(schema).to have_param(:animal_type, 'string')
      expect(schema).to have_param(:pet_measurements, 'object')
      expect(schema).to have_param(:pet_history, 'object')

      pm_schema = schema[:properties][:pet_measurements]
      expect(pm_schema).to have_param(:weight, 'number', {:description => "Weight in pounds"})
      expect(pm_schema).to have_param(:height, 'number', {:description => "Height in inches"})
      expect(pm_schema).to have_param(:num_legs, 'number', {:description => "Number of legs", :required => false})

      ph_schema = schema[:properties][:pet_history]
      expect(ph_schema).to have_param(:did_visit_vet, 'boolean')
      expect(ph_schema).to have_param(:avg_meals_per_day, 'number')
    end

    it "should return code matching :unprocessable_entity (422) with spread out 'pet' and 'num_fleas'" do
      returns_obj = subject.returns.detect{|e| e.code == 422 }

      puts returns_obj.to_json
      expect(returns_obj.code).to eq(422)

      expect(returns_obj).to match_param_structure([:pet_name,
                                                    :animal_type,
                                                    :num_fleas
                                                   ])
    end
    it 'should have the 422 response described in the swagger' do
      response = swagger_response_for('/pets/{id}/extra_info', 422)
      expect(response[:description]).to eq('Fleas were discovered on the pet')

      schema = response[:schema]
      expect(schema).to have_param(:pet_name, 'string', {:required => false})
      expect(schema).to have_param(:animal_type, 'string')
      expect(schema).to have_param(:num_fleas, 'number')
    end

  end

end
