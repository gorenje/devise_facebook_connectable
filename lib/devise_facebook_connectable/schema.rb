# encoding: utf-8
require 'devise/schema'

module Devise #:nodoc:
  module FacebookConnectable #:nodoc:
    module Schema
      # Database migration schema for Facebook Connect.
      #
      def facebook_connectable
        # BIGINT unsigned / 64-bit int
        facebook_apply_schema ::Devise::FacebookConnectable.uid_field, Integer, :limit => 8  
        # [128][1][20] chars
        facebook_apply_schema ::Devise::FacebookConnectable.session_key_field, String, :limit => 149  
      end

      protected 

      def facebook_apply_schema(*args)
        # Taken from:
        #   https://github.com/nbudin/devise_openid_authenticatable/blob/master/lib/devise_openid_authenticatable/schema.rb
        if respond_to?(:apply_devise_schema)
          apply_devise_schema *args
        else
          apply_schema *args
        end
      end
    end
  end
end

Devise::Schema.module_eval do
  include ::Devise::FacebookConnectable::Schema
end
