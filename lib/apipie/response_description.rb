module Apipie

  class ResponseDescription
    attr_reader :code, :description, :scope, :type_ref, :hash_validator

    def self.from_dsl_data(method_description, args)
      type_or_options, desc, options, default_scope = args
      Apipie::ResponseDescription.new(method_description, type_or_options,
                                   desc,
                                   options, default_scope)
    end

    def initialize(method_description, type_or_options, desc_or_options=nil, options={}, default_scope)

      if type_or_options.is_a? Hash
        @type_ref = options[:param_group]
        options = options.merge(type_or_options)
      else
        @type_ref = type_or_options
      end

      if desc_or_options.is_a? Hash
        @type_ref = type_or_options
        options = options.merge(desc_or_options)
      else
        desc = desc_or_options
      end

      @is_array_of = options[:array_of] || false
      raise ReturnsMultipleDefinitionError, type_or_options if @is_array_of && @type_ref

      @method_description = method_description
      @description = desc || options[:desc]
      @code = options[:code] || 200
      @scope = options[:scope] || default_scope

      if @type_ref.is_a? Symbol
        @param_group_block = Apipie.get_param_group(@scope, @type_ref)

        # create a fake ParamDescription with a HashValidator from the ParamGroup
        param_name = "returns"
        validator = Hash
        desc_or_options = "fake param"
        options = {:param_group => {:scope => default_scope, :name=>@type_ref, :options=>{}, :from_concern=>false}}
        block = @param_group_block
        param_description = ParamDescription.from_dsl_data(method_description, [param_name, validator, desc_or_options, options, block])
        @hash_validator = param_description.validator
      end

    end

    def params_ordered
      @hash_validator.params_ordered
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
