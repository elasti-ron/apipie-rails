require "json-schema"

#
module ActionController
    class Base

      # logs an error if output does not match schema, and optionally raises exception.
      # returns: true if the output matches the schema, false otherwise
      def err_if_swagger_schema_mismatch(output, response_code, verbose=true, raise_exception=false)
        Apipie.configuration.swagger_suppress_warnings = true
        # TODO: modify swagger_generator to return a json schema with stringified strings, not symbols
        unprocessed_schema = Apipie::json_schema_for_method_response(controller_name, action_name, response_code, true)
        raise "No response schema defined for #{controller_name}##{action_name}[#{response_code}]" unless unprocessed_schema

        schema = JSON.parse(JSON(unprocessed_schema))

        error_msg = "Apipie Response Validation failed: #{controller_name}##{action_name} response for HTTP code #{response_code} does not match declared structure"

        if verbose
          validation_result = JSON::Validator.fully_validate(schema, output, :strict => false, :version => :draft4, :json => true)
          valid = (validation_result == [])
          if !valid
            error_msg += ": " + validation_result.to_s
          end
        else
          valid = JSON::Validator.validate(schema, response.body, :strict => false, :version => :draft4, :json => true)
        end

        if !valid
          apipie_response_validation_error(controller_name, action_name, response.code, error_msg, schema, response.body, raise_exception)
        end

        valid
      end

      def render_with_validation(*args)
        result = render(*args)
        return result unless Apipie.configuration.response_validation

        err_if_swagger_schema_mismatch(response.body, response.code, Apipie.configuration.response_validation_verbose, Apipie.configuration.response_validation == :error)

        result
      end

      def apipie_response_validation_error(controller_name, method_name, return_code, error_msg, schema, returned_object, raise_exception=false)
        Rails.logger.warn(error_msg)
        if raise_exception
          # avoid DoubleRender error
          self.response_body = nil
          @_response_body = nil
          raise Apipie::ResponseDoesNotMatchSwaggerSchema.new(controller_name, method_name, return_code, error_msg, schema, returned_object)
        end
      end
  end
end