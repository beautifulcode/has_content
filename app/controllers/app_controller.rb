# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class AppController < ActionController::Base
  helper :all # include all helpers, all the time
  layout 'application'
end
