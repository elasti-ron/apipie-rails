module Apipie

  class ResponseObject
    include Apipie::DSL::Base
    include Apipie::DSL::Param

    # attr_reader :code, :description

    def initialize(method_description, code, scope, block)
      __tp("ResponseObject#initialize #{method_description.method} --> #{code} (#{block})")
      @method_description = method_description
      @scope = scope
      # @code = code
      @param_group = {scope: scope}

      self.instance_exec(&block) if block

      prepare_hash_params
    end

    # this routine overrides Param#_default_param_group_scope and is called if Param#param_group is
    # invoked during the instance_exec call in ResponseObject#initialize
    def _default_param_group_scope
      @scope
    end

    # def apipie_concern?
    #   @scope.apipie_concern?
    # end

    def name
      "response #{@code} for #{@method_description.method}"
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

      if code.is_a? Symbol
        @code = Rack::Utils::SYMBOL_TO_STATUS_CODE[code]
      else
        @code = code
      end

      @description = options[:desc]
      if @description.nil?
        @description = Rack::Utils::HTTP_STATUS_CODES[@code]
        raise "Cannot infer description from status code #{@code}" if @description.nil?
      end
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
