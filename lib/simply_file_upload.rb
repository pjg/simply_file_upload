require 'simply_file_upload_helpers'

# Helpers will be available in the views
ActionView::Base.send :include, SimplyFileUpload::Helpers

# Helpers will be available in all controllers
ActionController::Base.send :include, SimplyFileUpload::Helpers
