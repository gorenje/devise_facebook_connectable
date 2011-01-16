require 'cgi'
require 'digest/md5'

## Heavily modified, base code comes from
##  https://github.com/mmangino/facebooker/blob/master/lib/facebooker/rails/controller.rb
##
## Basically removed everything that was not necessary for cookie handling. This controller
## can only identify a user from the Facebook cookie - nothing else.
module Facebooker
  module Rails
    module Controller

      def self.included(controller)
        controller.class_eval do
          before_filter :set_facebook_session
        end
      end

      def facebook_session
        session["facebook_session"] || Devise::FacebookConnectable::Session.current
      end
      
      def set_facebook_session
        if facebook_cookie.present? && (session_set = secure_with_cookie)
          session[:facebook_session] = session_set
          Devise::FacebookConnectable::Session.current = session_set
        else
          clear_facebook_session_information
        end
      end
      
      def facebook_cookie_clear
        cookies[facebook_cookie_name].delete
      end
      
      def after_sign_out_path_for(scope_or_resource)
        ::Rails.logger.warn("clearing the cookie?")
        facebook_cookie_clear
        super
      end
      
      private
      
      def clear_facebook_session_information
        session[:facebook_session] = nil
        Devise::FacebookConnectable::Session.current = nil
      end
      
      def facebook_cookie_name
        "fbs_%s" % Devise::FacebookConnectable::Session.api_key
      end
      
      def facebook_cookie
        cookies[facebook_cookie_name]
      end
      
      def secure_with_cookie
        parsed = get_facebook_params_from_cookie(cookies[facebook_cookie_name])

        #returning gracefully if the cookies aren't set or have expired
        return unless (parsed['session_key'] && parsed['uid'] && 
                       parsed['expires'] && parsed['secret'])
        return unless ( (Time.at(parsed['expires'].to_s.to_f) > Time.now) || 
                        (parsed['expires'] == "0"))
        
        new_facebook_session.tap do |fb_session|
          fb_session.secure_with!(parsed['session_key'],parsed['uid'],
                                  parsed['expires'],parsed['secret'])
        end
      end
      
      ## Code based on
      ##   http://vombat.tumblr.com/post/835536630/ruby-version-of-facebooks-get-facebook-cookie-in-php
      def get_facebook_params_from_cookie(cookie)
        # unquote cookie value
        cookie.gsub!(/^"|"$/, '')

        # construct key, value pairs
        params = CGI.parse(cookie)
        
        # params contains keys and values of the form
        # {"session_key" => ["..abcdef.."], "uid" => ["123456789"]}
        # we need to unwrap each value out of the array into something like this
        # {"session_key" => "..abcdef..", "uid" => "123456789"}
        params = Hash[*params.sort.flatten]

        # take sig out
        sig     = params.delete("sig")
        payload = params.sort.collect { |key,value| "#{key}=#{value}" }.join
        
        return if sig != Digest::MD5.hexdigest(payload + Devise::FacebookConnectable.secret)
        return params
      end

      def new_facebook_session
        Devise::FacebookConnectable::Session.
          create(Devise::FacebookConnectable.api_id, Devise::FacebookConnectable.secret)
      end
    end
  end
end

ActionController::Base.send :include, Facebooker::Rails::Controller
