module Elvuel
	module OpenTaobao
		class UnkownHttpRequestMethodException < Exception;end
		class UnkownResponseFormatException < Exception;end
		class UnkownAppEnvException < Exception;end
		class UnkownAppTypeException < Exception;end
		class SessionKeyMissingException < Exception;end
		
		class AppKeyMissingException < Exception;end
		class AppKeyChangeDeniedException < Exception;end
		class AppSecretMissingException < Exception;end
		class InvalidOpenVersionException < Exception;end
		class FieldMissingException < Exception;end
	end
end