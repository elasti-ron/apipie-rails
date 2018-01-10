require 'spec_helper'
require 'rack/utils'


describe PetsController do

  let(:dsl_data) { ActionController::Base.send(:_apipie_dsl_data_init) }

  describe "PetsController#create" do
    subject do
      desc = Apipie.get_resource_description(PetsController, Apipie.configuration.default_version)
      desc._methods[:create_pet]
    end

    it "should return code 200 with a pet object" do
      response_obj = subject.responses.detect{|e| e.code == 200 }
      expect(response_obj.code).not_to be_nil

      expect(response_obj.params_ordered[0].name).to eq(:name)
      expect(response_obj.params_ordered[1].name).to eq(:animal)

      expect(response_obj.to_json).to eq({code: 200, description: nil, returns_object: [
          {:name=>"name", :full_name=>"returns[name]", :description=>"\n<p>Name of pet</p>\n", :required=>true, :allow_nil=>false, :allow_blank=>false, :validator=>"Must be a String", :expected_type=>"string", :metadata=>nil, :show=>true},
          {:name=>"animal", :full_name=>"returns[animal]", :description=>"\n<p>Type of pet</p>\n", :required=>true, :allow_nil=>false, :allow_blank=>false, :validator=>"Must be a String", :expected_type=>"string", :metadata=>nil, :show=>true}
      ]})
    end

    it "should return code 201 with a super_pet object" do
      returns_obj = subject.returns.detect{|e| e.code == 201 }

      puts returns_obj
      expect(returns_obj.code).not_to be_nil

      expect(returns_obj.params_ordered[0].name).to eq(:pet)
      expect(returns_obj.params_ordered[1].name).to eq(:superpower)
      expect(returns_obj.params_ordered[0].validator.class).to eq(Apipie::Validator::HashValidator)
      expect(returns_obj.params_ordered[0].validator.params_ordered[0].name).to eq(:name)
      expect(returns_obj.params_ordered[0].validator.params_ordered[1].name).to eq(:animal)

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

end