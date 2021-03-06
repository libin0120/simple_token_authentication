module SimpleTokenAuthentication
  class Entity
    def initialize(model, model_alias=nil)
      @model = model
      @name = model.name
      @name_underscore = model_alias.to_s unless model_alias.nil?
    end

    def model
      @model
    end

    def name
      @name
    end

    def name_underscore
      @name_underscore || name.underscore
    end

    # Private: Return the name of the header to watch for the token authentication param
    def token_header_name
      if SimpleTokenAuthentication.header_names["#{name_underscore}".to_sym].presence \
        && token_header_name = SimpleTokenAuthentication.header_names["#{name_underscore}".to_sym][:authentication_token]
        token_header_name
      else
        "X-#{name_underscore.camelize}-Token"
      end
    end

    # Private: Return the name of the header to watch for the email param
    def identifier_header_name
      if SimpleTokenAuthentication.header_names["#{name_underscore}".to_sym].presence \
        && identifier_header_name = SimpleTokenAuthentication.header_names["#{name_underscore}".to_sym][identifier]
        identifier_header_name
      else
        "X-#{name_underscore.camelize}-#{identifier.to_s.camelize}"
      end
    end

    def token_param_name
      if SimpleTokenAuthentication.param_names["#{name_underscore}".to_sym].presence \
        && token_param_name = SimpleTokenAuthentication.param_names["#{name_underscore}".to_sym][:authentication_token]
        token_param_name
      else
        "#{name_underscore}_token".to_sym
      end

    end

    def identifier_param_name
      if SimpleTokenAuthentication.param_names["#{name_underscore}".to_sym].presence \
        && identifier_param_name = SimpleTokenAuthentication.param_names["#{name_underscore}".to_sym][identifier]
        identifier_param_name
      else
        "#{name_underscore}_#{identifier}".to_sym
      end
    end

    def identifier
      if custom_identifier = SimpleTokenAuthentication.identifiers["#{name_underscore}".to_sym]
        custom_identifier.to_sym
      else
        :email
      end
    end

    def get_token_from_params_or_headers controller
      # if the token is not present among params, get it from headers
      if token = controller.params[token_param_name].blank? && controller.request.headers[token_header_name]
        controller.params[token_param_name] = token
      end
      controller.params[token_param_name]
    end

    def get_identifier_from_params_or_headers controller
      # if the identifier is not present among params, get it from headers
      if identifer_param = controller.params[identifier_param_name].blank? && controller.request.headers[identifier_header_name]
        controller.params[identifier_param_name] = identifer_param
      end
      controller.params[identifier_param_name]
    end
  end
end
