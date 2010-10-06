module Elvuel
  module OpenTaobao
    module Base
      
      class TaobaoAPIRequest
        attr_accessor :_request_method, :_request_uri, :_response_format, :_base_uri, :_session_key, :_api_version, :_app_key, :_app_secret

        def initialize(options={})
          options = {:session_key => Setting.session_key, :request_method => Setting.request_method, :response_format => Setting.response_format, :api_version => Setting.api_version, :app_key => Setting.app_key, :app_secret => Setting.app_secret}.merge(options)

          raise UnkownHttpRequestMethodException, "Unkown http request method: #{options[:request_method]}" unless Setting::REQUEST_METHODS.include?(options[:request_method])
  				raise UnkownResponseFormatException, "Unkown response format: #{options[:response_format]}" unless Setting::RESPONSE_FORMATS.include?(options[:response_format])

          if Setting::CAN_CHANGE_APP_KEY
            raise AppKeyMissingException, "App key missing." if options[:app_key].to_s.empty?
          else
            raise AppKeyChangeDeniedException, "Can not change the app_key.If you want to change the app_key set the constant CAN_CHANGE_APP_KEY to false." if options[:app_key].to_s != Setting::APP_KEY
          end
          
          raise AppSecretMissingException, "App secret missing." if options[:app_secret].to_s.empty? and Setting.app_env == Setting::APP_ENVS[-1]
          
          @_app_key = options[:app_key]
          @_app_secret = options[:app_secret]
  				@_session_key = options[:session_key]
  				@_request_method = options[:request_method].downcase
  				# if there are upload fields then the reqeust method must be 'post'!
  				@_request_method = "post" if self.upload_fields.length > 0
  				@_response_format = options[:response_format].downcase
  				@_api_version = options[:api_version]
  				@_base_uri = Setting.base_uri
  				@_base_uri = @_base_uri.gsub("?","") if @_request_method.eql?("post")
  				
  				@gbk = false
  				@files = []
        end
        
  			def url_encode(str)
  				#return str.gsub!(/[^\w$&\-+.,\/:;=?@]/) { |x| x = format("%%%x", x[0])}
  				URI.escape(str)
  			end
  			
  			def to_gbk(str)
  				Iconv.iconv("GBK//IGNORE","UTF-8//IGNORE",str).to_s
  			end

  			def to_utf(str)
  				Iconv.iconv("UTF-8//IGNORE","GBK//IGNORE",str).to_s
  			end
  			
  			def bgk?;@gbk;end
  			def gbk!;@gbk=true;end
  			def utf!;@gbk=false;end
        
  			def md5(s)
  				Digest::MD5.hexdigest(s)
  			end

  			def sign(params)
  				md5(@_app_secret + params.sort().collect{ |key, value| key+value}.join + @_app_secret).upcase
  			end
  			
  			def build_hash_params_for_request()
  				raise SessionKeyMissingException, "Current api:#{self.class.api_name},require session_key before request" if session_key_require? and @_session_key.to_s.empty?
  				
  				@time_stamp = Time.now
  				params = {}
  				params['app_key'] = @_app_key
  				params['format'] = @_response_format
  				params['method'] = self.class.api_name
  				params['v'] = @_api_version
  				params['session'] = @_session_key if session_key_require?
  				params['timestamp'] = @time_stamp.strftime("%Y-%m-%d %H:%M:%S")
  				params['sign_method'] = "md5"

  				api_params = all_params
  				if api_params.is_a?(String)
  					api_params = api_params.split(",")
  				end
          
          # reset files
          @files = []
          
  				unless api_params.empty?
  					api_params.each do |param|
  					  call_method = param
  					  call_method = param.gsub(".","_") if param.index(".")
  					  value = self.send(call_method.to_sym)
  					  
  					  raise FieldMissingException, "#{param} Can not be blank!" if self.require_fields.include?(param) and value.to_s.eql?("")

  					  # if upload_fields > 0 then do not set the upload field param!
  					  if self.upload_fields.include?(param)
                # not empty the can upload
  					    if value.to_s != ""
    					    filename = value.to_s.reverse.split("/")[0].reverse
    					    filename = filename.split(".")[0] if filename
    					    @files << { :file_name => filename, :field_name => param, :file_content => File.read(value)}
					      end
  					  else
                params[param] = value.to_s if value
					    end
  					end
	  			end
  	  		params
        end
        
        def send_request
          if @_request_method.eql?("get")
            params = build_hash_params_for_request
    				params = {'sign' => sign(params)}.merge(params)
    				begin
    				  body = ""
    				  Timeout::timeout(10) do
    				    body = HttpRequest.get({:url => @_base_uri, :parameters => params}).body
    			    end
    			    body = to_gbk(body) if @gbk
  				    if @_response_format == "xml"
  				      Crack::XML.parse(body)
				      else
				        Crack::JSON.parse(body)
			        end
    			  rescue
    			    raise
  			    end
          else
            params = build_hash_params_for_request
    				params = {'sign' => sign(params)}.merge(params)
    				options = {:url => @_base_uri, :parameters => params}
    				options.merge!(:files => @files) unless @files.empty?
    				begin
    				  Timeout::timeout(10) do
    				    body = HttpRequest.post(options).body
    				  end
    			    body = to_gbk(body) if @gbk
  				    if @_response_format == "xml"
  				      Crack::XML.parse(body)
				      else
				        Crack::JSON.parse(body)
			        end
  				  rescue# Exception => e
              raise
				    end
          end
        end
        
        def get_session_key_for_test(hook=false)
          appkey = @_app_key
    		  hr = HttpRequest
    		  url = "http://open.taobao.com/isv/authorize.php?appkey=#{appkey}"
    		  response = hr.get(url)
    		  hr.update_cookies(response)
    		  auth = hr.post({:url => url, :parameters => {"zhxz" => "1", "nick" => "alipublic00", "url" => "http://localhost:3000"}}).body
          auth.gsub!('<input type="text" id="autoInput" value="', "ELVUEL")
          auth =~ /ELVUEL(.[^"]*)"/
          authcode = $1
          url = ""
          session_key = ""
          if hook
            response = Net::HTTP.get_response(URI.parse("http://container.api.tbsandbox.com/container?authcode=#{authcode}"))
            case response
            # when Net::HTTPSuccess     then response
            when Net::HTTPRedirection
              url = response['location']
            else
              url = ""
            end
            session_key = url.split("top_session=")[1].split("&")[0] unless url.empty?
          else
            session_key = hr.get("http://container.api.tbsandbox.com/container?authcode=#{authcode}").body
          end
          session_key
        end
        
        protected
          # all request parameters
          def all_params;[];end
          # open api name
          def self.api_name;"";end
          # session_key
          def session_key_require?;false;end
          # require properties
          def require_fields;[];end
          # upload properties
          def upload_fields;[];end
        
      end

      class OpenIDLogin
        
      end
    end    
  end

end
