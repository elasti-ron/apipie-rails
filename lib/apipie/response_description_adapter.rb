module Apipie

  def self.prop(name, expected_type, options={}, sub_properties=[])
    Apipie::ResponseDescriptionAdapter::PropDesc.new(name, expected_type, options, sub_properties)
  end

  class ResponseDescriptionAdapter

    #
    # A ResponseDescriptionAdapter::PropDesc object pretends to be an Apipie::Param in a ResponseDescription
    #
    # To successfully masquerade as such, it needs to:
    #    respond_to?('name') and/or ['name'] returning the name of the parameter
    #    respond_to?('required') and/or ['required'] returning boolean
    #    respond_to?('validator') and/or ['validator'] returning 'nil' (so type is 'string'), or an object that:
    #           1) describes a type.  currently type is inferred as follows:
    #                 if validator.is_a? Apipie::Validator::EnumValidator -->  respond_to? 'values' (returns array).  Type is enum or boolean
    #                 else: use v.expected_type().  This is expected to be the swagger type, or:
    #                     numeric ==> swagger type is 'number'
    #                     hash ==> swagger type is 'object' and validator should respond_to? 'params_ordered'
    #                     array ==> swagger type is array and validator (FUTURE) should indicate type of element

    class PropDesc

      #
      # a ResponseDescriptionAdapter::PropDesc::Validator pretends to be an Apipie::Validator
      #
      class Validator
        attr_reader :expected_type

        def [](key)
          return self.send(key) if self.respond_to?(key.to_s)
        end

        def initialize(expected_type, enum_values=nil, sub_properties=nil)
          @expected_type = expected_type
          @enum_values = enum_values
          @is_enum = !!enum_values
          @sub_properties = sub_properties
        end

        def is_enum?
          !!@is_enum
        end

        def values
          @enum_values
        end

        def params_ordered
          raise "Only validators with expected_type 'object' can have sub-properties" unless @expected_type == 'object'
          @sub_properties
        end
      end

      #======================================================================


      def initialize(name, expected_type, options={}, sub_properties=[])
        @name = name
        @required = true
        @required = false if options[:required] == false
        @expected_type = expected_type

        options[:desc] ||= options[:description]
        @description = options[:desc]
        @options = options
        @sub_properties = []
        for prop in sub_properties do
          add_sub_property(prop)
        end
      end

      def [](key)
        return self.send(key) if self.respond_to?(key.to_s)
      end

      def add_sub_property(prop_desc)
        raise "Only properties with expected_type 'object' can have sub-properties" unless @expected_type == 'object'
        @sub_properties << prop_desc
      end

      def to_json(lang)
        {
            name: name,
            required: required,
            validator: validator,
            description: description,
            options: options
        }
      end
      attr_reader :name, :required, :expected_type, :options, :description
      alias_method :desc, :description

      def validator
        Validator.new(@expected_type, options[:values], @sub_properties)
      end
    end


    #======================================================================


    def self.from_self_describing_class(cls)
      adapter = ResponseDescriptionAdapter.new
      props = cls.describe_own_properties
      adapter.add_property_descriptions(props)
      adapter
    end

    def initialize
      @property_descs = []
    end

    def to_json
      params_ordered.to_json
    end

    def add(prop_desc)
      @property_descs << prop_desc
    end

    def add_property_descriptions(prop_descs)
      for prop_desc in prop_descs
        add(prop_desc)
      end
    end

    def property(name, expected_type, options)
      @property_descs << PropDesc.new(name, expected_type, options)
    end

    def params_ordered
      @property_descs
    end
  end
end
