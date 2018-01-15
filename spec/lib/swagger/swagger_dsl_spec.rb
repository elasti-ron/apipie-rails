require 'spec_helper'
require 'rack/utils'
require 'rspec/expectations'

describe PetsController do

  let(:dsl_data) { ActionController::Base.send(:_apipie_dsl_data_init) }
  let(:desc) { Apipie.get_resource_description(PetsController, Apipie.configuration.default_version) }

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
      expect(returns_obj.params_ordered[0].is_required?).to be_falsey
      expect(returns_obj.params_ordered[1].is_required?).to be_truthy
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

      expect(returns_obj).to match_param_structure([:pet_id, :pet_name, :animal_type])
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
                                                    {:pet_measurements => [:weight, :height, :num_legs]}
                                                    ])
    end

    it "should return code 203 with spread out 'pet', encapsulated 'pet_measurements' and encapsulated 'pet_history'" do
      returns_obj = subject.returns.detect{|e| e.code == 203 }

      puts returns_obj.to_json
      expect(returns_obj.code).to eq(203)

      expect(returns_obj).to match_param_structure([:pet_name,
                                                    :animal_type,
                                                    {:pet_measurements => [:weight, :height,:num_legs]},
                                                    {:pet_history => [:did_visit_vet, :avg_meals_per_day]}
                                                   ])
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

  end

end
