# encoding: utf-8
require 'devise/strategies/base'

module Devise #:nodoc:
  module FacebookConnectable #:nodoc:
    module Strategies #:nodoc:

      # Default strategy for signing in a user using Facebook Connect (a Facebook account).
      # Redirects to sign_in page if it's not authenticated
      #
      class FacebookConnectable < ::Devise::Strategies::Base

        # Without a Facebook session authentication cannot proceed.
        #
        def valid?
          mapping.to.respond_to?('authenticate_with_facebook_connect') && 
            Devise::FacebookConnectable::Session.current.present?
        end

        # Authenticate user with Facebook Connect.
        #
        def authenticate!
          klass = mapping.to

          begin
            facebook_session = Devise::FacebookConnectable::Session.current
            user = klass.authenticate_with_facebook_connect(:uid => facebook_session.uid)

            if user.present?
              success!(user)
            else
              if klass.facebook_auto_create_account?
                user = returning(klass.new) do |u|
                  u.store_facebook_credentials!(:session_key => facebook_session.session_key,
                                                :uid => facebook_session.uid)
                  u.on_before_facebook_connect(facebook_session)
                end

                begin
                  user.save(false)
                  user.on_after_facebook_connect(facebook_session)
                  success!(user)
                rescue
                  fail!(:facebook_invalid)
                end
              else
                fail!(:facebook_invalid)
              end
            end
            # NOTE: Facebooker::Session::SessionExpired errors handled in the controller.
          rescue => e
            fail!(e.message)
          end
        end
      end
    end
  end
end

Warden::Strategies.add(:facebook_connectable, 
                       Devise::FacebookConnectable::Strategies::FacebookConnectable)
