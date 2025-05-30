require 'open-uri'

module AresMUSH
  module Website
    
    class FileUpdateRequestHandler
      def handle(request)
        enactor = request.enactor
        name = request.args['name']
        folder = request.args['folder']
        new_description = Website.format_input_for_mush(request.args['new_description'])
        new_name = (request.args['new_name'] || "").downcase
        new_folder = (request.args['new_folder'] || "").downcase

        error = Website.check_login(request)
        return error if error
        
        request.log_request
        
        if (!Website.can_edit_wiki_file?(enactor, folder))
          return { error: t('dispatcher.not_allowed') }
        end
        
        new_name = AresMUSH::Website::FilenameSanitizer.sanitize new_name
        new_folder = AresMUSH::Website::FilenameSanitizer.sanitize new_folder
        
        path = File.join(AresMUSH.website_uploads_path, folder, name)
        new_folder_path = File.join(AresMUSH.website_uploads_path, new_folder)
        new_path = File.join(new_folder_path, new_name)
        
        if (!File.exist?(path))
          return { error: t('webportal.not_found') }
        end
        
        if (new_name.blank? || new_folder.blank?)
          return { error: t('webportal.missing_required_fields', :fields => "name, folder") }
        end
        
        if (File.exist?(new_path) && path != new_path)
          return { error: t('webportal.file_already_exists')  }
        end
        
        if (folder == "theme_images" && !enactor.is_admin?)
          return { error: t('webportal.theme_locked_to_admin') }
        end
        
        if (!Dir.exist?(new_folder_path))
          Dir.mkdir(new_folder_path)
        end
        
        file_meta = WikiFileMeta.find_meta(folder, name)
        if (file_meta)
          file_meta.update(description: new_description, name: new_name, folder: new_folder)
        else
          WikiFileMeta.create(name: new_name, folder: new_folder, description: new_description)
        end

        if (path != new_path)
          FileUtils.mv(path, new_path)
        end
        
        Website.add_to_recent_changes('file', t('webportal.file_moved', :name => "#{folder}/#{name}"), { name: new_name, folder: new_folder }, enactor.name)
        
        
        {
          path: new_path.gsub(AresMUSH.website_uploads_path, ''),
          folder: new_folder,
          name: new_name
        }
      end
    end
  end
end