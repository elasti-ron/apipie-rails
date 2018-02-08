require 'spec_helper'
require 'rack/utils'
require 'rspec/expectations'

RSpec.describe PetsController, :type => :controller do
  before :each do
    Apipie.configuration.response_validation = :warning
    Apipie.configuration.swagger_allow_additional_properties_in_response = false
  end

  it "does not detect error when rendered output matches the described response" do
    expect(controller).not_to receive(:apipie_response_validation_error)
    get :return_and_validate_expected_response, {format: :json}
  end

  it "does not detect error when rendered output (array) matches the described response" do
    expect(controller).not_to receive(:apipie_response_validation_error)
    get :return_and_validate_expected_array_response, {format: :json}
  end

  it "does not detect error when rendered output includes null in the response" do
    expect(controller).not_to receive(:apipie_response_validation_error)
    get :return_and_validate_expected_response_with_null, {format: :json}
  end

  it "does not detect error when rendered output includes null (instead of an object) in the response" do
    expect(controller).not_to receive(:apipie_response_validation_error)
    get :return_and_validate_expected_response_with_null_object, {format: :json}
  end

  it "detects error when a response field has the wrong type" do
    expect(controller).to receive(:apipie_response_validation_error).with("pets", "return_and_validate_type_mismatch", "200", any_args)
    get :return_and_validate_type_mismatch, {format: :json}
  end

  it "detects error when a response has a missing field" do
    expect(controller).to receive(:apipie_response_validation_error).with("pets", "return_and_validate_missing_field", "200", any_args)
    get :return_and_validate_missing_field, {format: :json}
  end

  it "detects error when a response has an extra field and 'swagger_allow_additional_properties_in_response' is false" do
    expect(controller).to receive(:apipie_response_validation_error).with("pets", "return_and_validate_extra_field", "200", any_args)
    get :return_and_validate_extra_field, {format: :json}
  end

  it "detects error when a response has is array instead of object" do
    # note: this action returns HTTP 201, not HTTP 200!
    expect(controller).to receive(:apipie_response_validation_error).with("pets", "return_and_validate_unexpected_array_response", "201", any_args)
    get :return_and_validate_unexpected_array_response, {format: :json}
  end

  it "does not detect error when a response has an extra field and 'swagger_allow_additional_properties_in_response' is true" do
    Apipie.configuration.swagger_allow_additional_properties_in_response = true
    expect(controller).not_to receive(:apipie_response_validation_error)
    get :return_and_validate_extra_field, {format: :json}
  end

  it "raises exception when a response field has the wrong type and response_validation is set to :error" do
    Apipie.configuration.response_validation = :error
    # expect(controller).to receive(:apipie_response_validation_error).with("pets", "return_and_validate_type_mismatch", "200", any_args)
    expect { get :return_and_validate_type_mismatch, {format: :json} }.to raise_error(Apipie::ResponseDoesNotMatchSwaggerSchema)
  end


end