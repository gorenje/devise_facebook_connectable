##
## The following are taken from facebooker gem
##  https://github.com/mmangino/facebooker/blob/master/lib/facebooker/rails/helpers/fb_connect.rb
##
module Devise #:nodoc:
  module Facebooker #:nodoc:
    module Helpers
      #
      # Render an <fb:login-button> element
      #
      # ==== Examples
      #
      #   <%= fb_login_button%>
      #   => <fb:login-button></fb:login-button>
      #
      # Specifying a javascript callback
      #
      #   <%= fb_login_button 'update_something();'%>
      #   => <fb:login-button onlogin='update_something();'></fb:login-button>
      #
      # Adding options <em>See:</em> http://wiki.developers.facebook.com/index.php/Fb:login-button
      #
      #   <%= fb_login_button 'update_something();', :size => :small, :background => :dark%>
      #   => <fb:login-button background='dark' onlogin='update_something();' size='small'></fb:login-button>
      #
      # :text option allows you to set the text value of the
      # button.  *A note!* This will only do what you expect it to do
      # if you set :v => 2 as well.
      #
      #   <%= fb_login_button 'update_somethign();',
      #        :text => 'Loginto Facebook', :v => 2 %>
      #   => <fb:login-button v='2' onlogin='update_something();'>Login to Facebook</fb:login-button>
      def fb_login_button(*args)
        callback = args.first
        options = args[1] || {}
        options.merge!(:onlogin=>callback) if callback

        text = options.delete(:text)

        content_tag("fb:login-button", text, options)
      end
    end
  end
end

::ActionView::Base.send :include, Devise::Facebooker::Helpers
