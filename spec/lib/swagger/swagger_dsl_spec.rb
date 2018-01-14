require 'spec_helper'
require 'rack/utils'
require 'rspec/expectations'

RSpec::Matchers.define :match_param_structure do |expected|
  num = 0
  match do |actual|
    for pdesc in expected do
      if pdesc.is_a? Symbol
        if ( actual.params_ordered[num].name.to_sym != pdesc.to_sym )
          puts "#{actual.params_ordered[num].name} != #{pdesc}"
          return false
        end
      elsif pdesc.is_a? Hash
        if ( actual.params_ordered[num].name.to_sym != pdesc.keys[0].to_sym)
          puts "Name of Hash <#{actual.params_ordered[num].name}> != <#{pdesc.keys[0]}>"
          return false
        end
        expect(actual.params_ordered[num].validator).to match_param_structure(pdesc.values[0])
      end
      num+=1
    end
    puts "param count: #{actual.params_ordered.count} != #{num}" if actual.params_ordered.count != num
    actual.params_ordered.count == num
  end
end

describe PetsController do

  let(:dsl_data) { ActionController::Base.send(:_apipie_dsl_data_init) }
  let(:desc) { Apipie.get_resource_description(PetsController, Apipie.configuration.default_version) }

  def match()

  end

  describe "PetsController#show_as_properties" do
    subject do
      desc._methods[:show_as_properties]
    end

    it "should return code 200 with 'pet_name' and 'animal_type'" do
      returns_obj = subject.returns.detect{|e| e.code == 200 }

      puts returns_obj.to_json
      expect(returns_obj.code).to eq(200)

      expect(returns_obj).to match_param_structure([:pet_name, :animal_type])
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

      expect(returns_obj).to match_param_structure([:pet_name, :animal_type])
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

      expect(returns_obj).to match_param_structure([:owner_name, :vote])
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

      expect(returns_obj).to match_param_structure([:pet_name, :animal_type])
    end

    it "should return code 202 with spread out 'pet' and encapsulated 'pet_measurements'" do
      returns_obj = subject.returns.detect{|e| e.code == 202 }

      puts returns_obj.to_json
      expect(returns_obj.code).to eq(202)

      expect(returns_obj).to match_param_structure([:pet_name,
                                                    :animal_type,
                                                    {:pet_measurements => [:weight, :height, :num_legs]
                                                    }])
    end

    it "should return code 203 with spread out 'pet', encapsulated 'pet_measurements' and encapsulated 'pet_history'" do
      returns_obj = subject.returns.detect{|e| e.code == 203 }

      puts returns_obj.to_json
      expect(returns_obj.code).to eq(203)

      expect(returns_obj).to match_param_structure([:pet_name,
                                                    :animal_type,
                                                    {:pet_measurements => [:weight, :height,:num_legs] },
                                                    {:pet_history => [:did_visit_vet, :avg_meals_per_day]}
                                                   ])
    end

    it "should return code 204 with spread out 'pet' and 'num_fleas'" do
      returns_obj = subject.returns.detect{|e| e.code == 204 }

      puts returns_obj.to_json
      expect(returns_obj.code).to eq(204)

      expect(returns_obj).to match_param_structure([:pet_name,
                                                    :animal_type,
                                                    :num_fleas
                                                   ])
    end

  end



end

describe "TBD" do

  it "should return code 202 with a pet object" do
      returns_obj = subject.returns.detect{|e| e.code == 202 }

      puts returns_obj.to_json
      expect(returns_obj.code).to eq(202)

      expect(returns_obj.params_ordered[0].name).to eq(:pet_inner_hash)
      expect(returns_obj.params_ordered[0].validator.class).to eq(Apipie::Validator::HashValidator)
      expect(returns_obj.params_ordered[0].validator.params_ordered[0].name).to eq(:name)
      expect(returns_obj.params_ordered[0].validator.params_ordered[1].name).to eq(:animal)
    end

    it "should return code 203 with pet and super_pet object" do
      returns_obj = subject.returns.detect{|e| e.code == 203 }

      puts returns_obj.to_json
      expect(returns_obj.code).to eq(203)

      expect(returns_obj.params_ordered[0].name).to eq(:super_pet_inner_hash)
      expect(returns_obj.params_ordered[0].validator.class).to eq(Apipie::Validator::HashValidator)
      expect(returns_obj.params_ordered[0].validator.params_ordered[0].name).to eq(:pet_inner_hash)
      expect(returns_obj.params_ordered[0].validator.params_ordered[0].validator.params_ordered[0].name).to eq(:name)
      expect(returns_obj.params_ordered[0].validator.params_ordered[0].validator.params_ordered[1].name).to eq(:animal)
      expect(returns_obj.params_ordered[1].name).to eq(:pet_inner_hash)
      expect(returns_obj.params_ordered[1].validator.class).to eq(Apipie::Validator::HashValidator)
      expect(returns_obj.params_ordered[1].validator.params_ordered[0].name).to eq(:name)
      expect(returns_obj.params_ordered[1].validator.params_ordered[1].name).to eq(:animal)
    end

    it "should return code 204 with :code1 (Number) and :code2 (Enum)" do
      returns_obj = subject.returns.detect{|e| e.code == 204 }

      puts returns_obj.to_json
      expect(returns_obj.code).to eq(204)

      expect(returns_obj.params_ordered[0].name).to eq(:code1)
      expect(returns_obj.params_ordered[0].validator.class).to eq(Apipie::Validator::IntegerValidator)
      expect(returns_obj.params_ordered[1].name).to eq(:code2)
      expect(returns_obj.params_ordered[1].validator.class).to eq(Apipie::Validator::EnumValidator)
      expect(returns_obj.params_ordered[1].only_in_response).to be_truthy
    end

  end

  describe "UsersController#create" do
    subject do
      desc = Apipie.get_resource_description(UsersController, Apipie.configuration.default_version)
      desc._methods[:create]
    end

    it "should indicate :unprocessable_entity as a possible error" do
      expect(subject.errors.map{|e| e.code}).to include(Rack::Utils::SYMBOL_TO_STATUS_CODE[:unprocessable_entity])
    end

    it "lets reuse the params description in more actions" do
      user_create_desc = Apipie["users#create"].params[:user]
      user_create_params = user_create_desc.validator.params_ordered.map(&:name)

      user_update_desc = Apipie["users#update"].params[:user]
      user_update_params = user_update_desc.validator.params_ordered.map(&:name)

      common = user_update_params & user_create_params
      expect(common.sort_by(&:to_s)).to eq(user_update_params.sort_by(&:to_s))
    end

  end

  describe "UsersController#index" do
    subject do
      desc = Apipie.get_resource_description(UsersController, Apipie.configuration.default_version)
      desc._methods[:index]
    end

    it "should indicate :unprocessable_entity as a possible error" do
      expect(subject.errors.map{|e| e.code}).to include(404)
    end

    pending "supports concerns dsl" # https://github.com/Apipie/apipie-rails#concerns

  end
