require 'rubygems'
require "net/http"
require "open-uri"
require "iconv"
require "digest/md5"
require 'crack'

require File.join(File.dirname(__FILE__), '/http_request')
require File.join(File.dirname(__FILE__), '/exception')
require File.join(File.dirname(__FILE__), '/api')
require File.join(File.dirname(__FILE__), '/base_setting')
require File.join(File.dirname(__FILE__), '/base_request')

module Elvuel
  module OpenTaobao
    class << self
      def version;"2.0-pre";end
      def author;"elvuel\nelvuel@gmail.com";end
    end
    
		def self.included(base)
			API.list.each do |api|
				klass = self.const_set("#{Base::Setting::DYNAMIC_CLASS_NAME_PREFIX}#{api[:name_dynamic]}",Class.new(Base::TaobaoAPIRequest))
				api_params = api[:params].join(",")
				api_params.gsub!(".","_")
				
				s = "attr_accessor :#{api_params.gsub(',',', :').gsub(/\*|!/,"")}\n"

        require_fields = []
        upload_fields = []
        api[:params].each do |method|
          param_name = method.gsub(/\*|!/,"")
          if method.index("*")
            require_fields <<  param_name
            def_str = "def #{method.gsub(".","_").gsub(/\*|!/,"")}=(v)\n"
            def_str << "\traise FieldMissingException, \"#{method.gsub('*','')} Can not be blank!\" if v.to_s.empty?\n"
            def_str << "\t@#{method.gsub(".","_").gsub(/\*|!/,"")}=v\n"
            def_str << "end\n"
            s << def_str
          end
          upload_fields << param_name if method.index("!")
        end
			  
				s << "def all_params;%w(#{api[:params].join(" ").gsub(/\*|!/,"")});end\n"
				s << "def self.api_name;\"#{api[:name]}\";end\n"
				s << "def session_key_require?;#{api[:session_key_require]};end\n"
				s << "def require_fields;%w(#{require_fields.join(" ")});end\n"
				s << "def upload_fields;%w(#{upload_fields.join(" ")});end\n"
				s << "#\n{api[:add_methods].to_s}\n" unless api[:add_methods].empty?

				klass.module_eval(s)
			end
	  end
  end
end




