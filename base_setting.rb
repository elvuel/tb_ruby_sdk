module Elvuel
  module OpenTaobao
    module Base
      module Setting
        
        DYNAMIC_CLASS_NAME_PREFIX = "TB".freeze

				CAN_CHANGE_APP_KEY = true
				
				RESPONSE_FORMATS = %w(xml json)
				REQUEST_METHODS = %w(get post)

				APP_ENVS = %w(test development production).freeze # td => test and development
        APP_KEY = "your key".freeze
        APP_SECRET = "app secret".freeze
				SESSION_KEY = ""

				API_VERSION = "2.0".freeze
				
				APP_TYPE = %w(web client)
				
				@response_format = RESPONSE_FORMATS[0]
				@request_method = REQUEST_METHODS[0]
        
        @app_env = APP_ENVS[0]
        @app_key = APP_KEY
        @app_secret = APP_SECRET
        @session_key = SESSION_KEY
        
        @api_version = API_VERSION
        @app_type = APP_TYPE[0]
        
        class << self
          attr_accessor :app_key, :app_secret, :session_key, :api_version, :app_env, :response_format, :request_method, :app_type
          
          def setting_reset!
    				@response_format = RESPONSE_FORMATS[0]
    				@request_method = REQUEST_METHODS[0]

            @app_env = APP_ENVS[0]
            @app_key = APP_KEY
            @app_secret = APP_SECRET
            @session_key = SESSION_KEY

            @api_version = API_VERSION
            @app_type = APP_TYPE[0]
          end
          
          def app_key=(key)
            if CAN_CHANGE_APP_KEY
              @app_key = key
            else
      				raise AppKeyChangeDeniedException, "Can not change the app_key.If you wanna to change the app_key set the constant CAN_CHANGE_APP_KEY to false."
            end
          end
          
          # setting response format
          def response_format=(format)
						v = format.to_s.downcase
						if RESPONSE_FORMATS.include?(v)
							@response_format = v
						else
						  raise UnkownResponseFormatException, "Unkown response format.The format '#{format}' not in '[#{RESPONSE_FORMATS.join(",")}]'"
						end
          end
          
          def request_method=(method)
            v = method.to_s.downcase
            if REQUEST_METHODS.include?(v)
              @request_method = v
            else
						  raise UnkownResponseFormatException, "Unkown request method.The method '#{method}' not in '[#{REQUEST_METHODS.join(",")}]'"              
            end
          end
        
          def app_env=(env)
            v = env.to_s.downcase
            if APP_ENVS.include?(v)
              @app_env = v
            else
						  raise UnkownAppEnvException, "Unkown app env.The env '#{env}' not in '[#{APP_ENVS.join(",")}]'"              
            end
          end
          
          def app_type=(type)
            v = type.to_s.downcase
            if APP_TYPE.include?(v)
              @app_type = v
            else
						  raise UnkownAppTypeException, "Unkown app type.The type '#{type}' not in '[#{APP_TYPE.join(",")}]'"              
            end
          end
          
					def base_uri
						if APP_ENVS[-1].eql?(@app_env)
							"http://gw.api.taobao.com/router/rest?"
						else
              # self.app_key = "test"
              # self.app_secret = ""
							"http://gw.api.tbsandbox.com/router/rest?"
						end
					end
					
        end
        
      end
      
    end
  end
end
