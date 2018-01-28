require "json-schema"

module ActionController
  module Instrumentation
    def render_with_validation(*args)
      return unless Apipie.configuration.response_validation

      Apipie.configuration.swagger_suppress_warnings = true

      result = render(*args)

      # TODO: modify swagger_generator to return a json schema with stringified strings, not symbols
      schema = JSON.parse(JSON(Apipie::json_schema_for_method_response(controller_name, action_name, response.code)))

      if !JSON::Validator.validate(schema, response.body, :strict => false, :version => :draft4, :json => true)
        apipie_response_validation_error(controller_name, action_name, response.code)
      end

      result
    end

    def apipie_response_validation_error(controller_name, action_name, response_code)
      Rails.logger.warn("Apipie Response Validation Warning: #{controller_name}##{action_name} response for HTTP code #{response_code} does not match declared structure")
      raise "Response for code #{response.code} does not match declared structure" if Apipie.configuration.response_validation == :error
    end
  end
end