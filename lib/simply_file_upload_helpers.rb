module SimplyFileUpload

  module Helpers

    # opts for the file_upload_form HELPER
    #
    #   :title -> title for the dialog box
    #   :action -> form action attribute (file upload route)
    #   :directory -> directory to upload the file to
    #   :filename -> force destination filename [OPTIONAL]
    #   :callback -> rake task to execute after the file has been uploaded [OPTIONAL] (note that the rake task must be in the maintenance namespace, like this: rake maintenance:make_thumbnail)
    #
    def file_upload_form(opts = {})

      # html params for the button tag
      params = {}

      # parse params from the function call
      params[:"data-title"] = opts[:title]
      params[:"data-action"] = opts[:action] || ''
      params[:"data-directory"] = opts[:directory] || '/pictures'
      params[:"data-filename"] = opts[:filename] # nil if not specified
      params[:"data-callback"] = opts[:callback] # nil if not specified

      # params for the HTML tag
      params[:type] = 'button'
      params[:class] = 'file_upload_button'

      content_tag :button, 'Wgraj plik', params
    end

    # Controller method to handle the file upload
    def process_file_upload
      if params[:file].present? and params[:file].respond_to?(:size) and params[:file].size != 0
        # there is an actual file being uploaded
        filename = params[:filename].present? ? params[:filename] : params[:file].original_filename.sanitize_as_filename
        directory = File.join("#{RAILS_ROOT}", "/public/", params[:directory])
        full_path = File.join(directory, filename)

        # no directory by that name
        error_msg = 'Błąd: nie ma katalogu, do którego można wgrać plik.' if !File.directory?(directory)

        # file already exists
        if File.exist?(full_path)
          # overwrite existing file?
          if params[:overwrite] == 'on'
            # overwrite, but also save a timestamped backup copy
            backup_filename = File.basename(filename, File.extname(filename)) + ".#{Time.now.strftime("%Y%m%d%H%M%S")}" + File.extname(filename)
            begin
              File.rename(full_path, File.join(directory, backup_filename))
            rescue SystemCallError
              error_msg = 'Błąd: nie mogę utworzyć kopii zapasowej istniejącego pliku.'
            end
          else
            error_msg = 'Błąd: istnieje już plik o tej nazwie.'
          end
        end
      else
        # no file uploaded
        error_msg = 'Błąd: brak pliku do wgrania.'
      end

      # render response in parent frame (parent of the iframe object) (requires responds_to_parent plugin)
      responds_to_parent do
        render :update do |page|

          # remove the spinner
          page[".file_upload_box .loading"].remove

          if error_msg.present?
            # display errors
            page['.file_upload_box .message'].attr 'class', 'message alert'
            page['.file_upload_box .message'].text error_msg
          else
            # actually save the file
            File.open(full_path , "wb") {|f| f.write(params[:file].read)}
            File.chmod(0644, full_path)

            # execute callback task if present
            if params[:callback].present?
              # allowing system callbacks is a very serious security risk (but we still want them), so we drastically limit allowed characters
              callback = params[:callback].gsub(/[^a-z A-Z0-9=\/\.\_-]/, '')
              system("rake maintenance:#{callback}")
            end

            # message for the user
            page['.file_upload_box .message'].attr 'class', 'message notice'
            page['.file_upload_box .message'].text 'Plik wgrany pomyślnie.'
          end
        end
      end
    end
  end
end
