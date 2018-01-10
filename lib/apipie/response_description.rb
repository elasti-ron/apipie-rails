module Apipie

  class ResponseObject
    include Apipie::DSL::Base
    include Apipie::DSL::Param

    def initialize(method_description, code, scope, block)
      __tp("ResponseObject#initialize #{method_description.method} --> #{code} (#{block})")
      @method_description = method_description
      @param_group = {scope: scope}

      self.instance_exec(&block)

      prepare_hash_params
    end

    def params_ordered
      __tp("ResponseObject#params_ordered (_apipie_dsl_data: #{_apipie_dsl_data}")
      @params_ordered ||= _apipie_dsl_data[:params].map do |args|
        options = args.find { |arg| arg.is_a? Hash }
        options[:param_group] = @param_group
        Apipie::ParamDescription.from_dsl_data(@method_description, args)
      end
    end

    def prepare_hash_params
      @hash_params = params_ordered.reduce({}) do |h, param|
        h.update(param.name.to_sym => param)
      end
    end

  end



  class ResponseDescription
    include Apipie::DSL::Base
    include Apipie::DSL::Param

    attr_reader :code, :description, :scope, :type_ref, :hash_validator

    def self.from_dsl_data(method_description, code, returns_args, properties_dsl_data)
      options, scope, block = returns_args

      Apipie::ResponseDescription.new(method_description,
                                      code,
                                      options,
                                      scope,
                                      block,
                                      properties_dsl_data)
    end

    def initialize(method_description, code, options, scope, block, properties_dsl_data)

      __tp("ResponseDescription#initialize code: #{code} options:#{options} properties_dsl_data:#{properties_dsl_data}")

      @type_ref = options[:param_group]
      @is_array_of = options[:array_of] || false
      raise ReturnsMultipleDefinitionError, type_or_options if @is_array_of && @type_ref

      @method_description = method_description
      @description = options[:desc]
      @code = code
      @scope = scope

      @response_object = ResponseObject.new(method_description, code, scope, block)
    end

    def param_description
      nil
    end

    # def params_ordered
    #   @params_ordered ||= _apipie_dsl_data[:params].map do |args|
    #     options = args.find { |arg| arg.is_a? Hash }
    #     options[:parent] = self.param_description
    #     Apipie::ParamDescription.from_dsl_data(param_description.method_description, args)
    #   end
    # end

    def params_ordered
      @response_object.params_ordered
    end

    def to_json(lang=nil)
      {
          :code => code,
          :description => description,
          :returns_object => params_ordered.map{ |param| param.to_json(lang).tap{|h| h.delete(:validations) }}.flatten,
      }
    end
  end
end
