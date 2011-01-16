# The intention here is to implement just enough of the facebooker gem
# (https://github.com/mmangino/facebooker) so that facebook for devise
# will work with Rails 3. Basically what we're doing is taking the session
# handling out of the facebooker plugin and putting it here.
#
# Code taken from
#  https://github.com/mmangino/facebooker/blob/master/lib/facebooker/session.rb
module Devise
  module FacebookConnectable
    class Session
      attr_reader :session_key
      attr_reader :uid
      
      def self.current
        Thread.current['facebook_session']
      end

      def self.current=(session)
        Thread.current['facebook_session'] = session
      end

      def self.api_key
        Devise::FacebookConnectable.api_id
      end
      
      def self.secret_key
        Devise::FacebookConnectable.secret
      end
      
      def self.create(api_key=nil, secret_key=nil)
        api_key ||= self.api_key
        secret_key ||= self.secret_key
        raise ArgumentError unless !api_key.nil? && !secret_key.nil?
        new(api_key, secret_key)
      end

      def initialize(api_key, secret_key)
        @api_key        = api_key
        @secret_key     = secret_key
        @batch_request  = nil
        @session_key    = nil
        @uid            = nil
        @auth_token     = nil
        @secret_from_session = nil
        @expires        = nil
      end
      
      def secure_with!(session_key, uid = nil, expires = nil, secret_from_session = nil)
        @session_key         = session_key
        @uid                 = Integer(uid)
        @expires             = expires ? Integer(expires) : 0
        @secret_from_session = secret_from_session
      end
    end
  end
end
