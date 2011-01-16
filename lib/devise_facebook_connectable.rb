# encoding: utf-8
require 'devise'

module Devise
  module FacebookConnectable
  end
end

require 'devise_facebook_connectable/facebooker/controller'
require 'devise_facebook_connectable/facebooker/session'
require 'devise_facebook_connectable/facebooker/view_helpers'
require 'devise_facebook_connectable/version'
require 'devise_facebook_connectable/model'
require 'devise_facebook_connectable/strategy'
require 'devise_facebook_connectable/schema'
require 'devise_facebook_connectable/view_helpers'

module Devise
  module FacebookConnectable
    # Specifies the name of the database column name used for storing
    # the user Facebook UID. Useful if this info should be saved in a
    # generic column if different authentication solutions are used.
    mattr_accessor :uid_field
    @@uid_field = :facebook_uid

    # Specifies the name of the database column name used for storing
    # the user Facebook session key. Useful if this info should be saved in a
    # generic column if different authentication solutions are used.
    mattr_accessor :session_key_field
    @@session_key_field = :facebook_session_key

    # Specifies if account should be created if no account exists for
    # a specified Facebook UID or not.
    mattr_accessor :auto_create_account
    @@auto_create_account = true

    # Specific application details, these need to be set in an initializer:
    #   Devise::FacebookConnectable.setup do |config|
    #     config.api_id = ApiKeys.facebook.api_id
    #     config.api_token = ApiKeys.facebook.api_token
    #     config.secret = ApiKeys.facebook.secret
    #   end
    mattr_accessor :api_id
    mattr_accessor :api_token
    mattr_accessor :secret
    
    def self.setup
      yield self
    end
  end
end

# Load core I18n locales: en
#
I18n.load_path.unshift(File.join(File.dirname(__FILE__), 
                                 *%w[devise_facebook_connectable locales en.yml]))

# Add +:facebook_connectable+ strategies to defaults.
#
Devise.add_module(:facebook_connectable,
  :strategy => true,
  :controller => :sessions,
  :model => 'devise_facebook_connectable/model')
