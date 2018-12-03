module Ubiquity

  class JsonImporter
    attr_reader :ubiquity_model_class

    def initialize(data)
      @data = data
      $stdout.puts "Log Json data loaded #{@data}"

      @data_id  = data.delete('id') || data.delete(:id)
      @tenant = data['tenant'] || data[:tenant]
      @domain = data['domain'] || data[:domain]

      @tenant_domain = @tenant + '.' + @domain
      #@data_hash = HashWithIndifferentAccess.new(data.first)
      @data_hash = HashWithIndifferentAccess.new(data)
      @file = @data_hash[:file]
      @ubiquity_model_class = @data_hash["type"].constantize
      @work_instance = model_instance
    end

    def run
      AccountElevator.switch!("#{@tenant_domain}")
      email = Hyrax.config.batch_user_key

      @user = User.where(email: @work_instance.depositor).first ||  User.find_or_create_by(email: email) { |user|  user.password = 'abcdefgh'; user.password_confirmation = 'abcdefgh'}

      @work_instance.depositor = @user.email unless @work_instance.depositor
      $stdout.puts "Started parsing the json data"

      @work_instance.attributes.each do |key, val|
        populate_array_field(key, val)
        populate_json_field(key, val)
        populate_single_fields(key, val)
      end
      @work_instance.date_modified = Hyrax::TimeService.time_in_utc
      @work_instance.date_uploaded = Hyrax::TimeService.time_in_utc unless @work_instance.date_uploaded.present?
      @work_instance.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE unless @work_instance.visibility.present?
      @work_instance.save!
      add_state_to_work
      $stdout.puts "work was successfully created"

      attach_files
      @work_instance
    end

    private

    def model_instance
      AccountElevator.switch!("#{@tenant_domain}")
      if work = ubiquity_model_class.where(id: @data_id).first
        work
      else
        new_work
      end

      rescue ActiveFedora::ObjectNotFoundError
        new_work
    end

    def new_work
      return ubiquity_model_class.new(id: @data_id)  if @data_id.present?
      ubiquity_model_class.new
    end

    def add_state_to_work
      work = @work_instance
      state = Sipity::WorkflowState.where(name: "deposited").first
      sipity_entity = Sipity::Entity.where(proxy_for_global_id: work.to_global_id.to_s).first

      if state.present? && (not sipity_entity.present?)
        #Sipity::Entity.find_or_create_by(proxy_for_global_id: work.to_global_id.to_s, workflow_state: state, workflow: state.workflow)
        Sipity::Entity.create!(proxy_for_global_id: work.to_global_id.to_s, workflow_state: state, workflow: state.workflow)
      end
    end

    def  populate_array_field(key, val)
      if (@data_hash[key].present? && (@work_instance.send(key).respond_to? :length) && (not val.class == String) && (not ['creator', 'editor', 'contributor', 'alternate_identifier', 'related_identifier'].include? key))
        @work_instance.send("#{key}=", @data_hash[key].split('||'))
      end
    end

    def populate_json_field(key, val)
      if (@data_hash[key].present? && (@work_instance.send(key).respond_to? :length) && (not val.class == String) && (['creator', 'editor', 'contributor', 'alternate_identifier', 'related_identifier'].include? key))
         process_json_value(key)
        @work_instance.send("#{key}=", [@data_hash[key].to_json])
      end
    end

    def process_json_value(key)
      group_field_key = "#{key}_group"
      @work_instance.send("#{group_field_key}=", @data_hash[key])
    end

    def populate_single_fields(key, val)
      if (@data_hash[key].present? && (@data_hash[key].class == String) && (not val.class == ActiveTriples::Relation) && (not ['creator', 'editor', 'contributor', 'alternate_identifier', 'related_identifier'].include? key))
        @work_instance.send("#{key}=", @data_hash[key])
      end
    end

    def create_file_from_array
      @hyrax_uploaded_file = []
      file_array = @file.split('||')
      create_multiple_files(file_array)
    end

    def create_multiple_files(file_array)
      file_array.each do |file|
        create_file(file)
      end
    end

    def create_file(file)
      if file.present? && file =~ /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$/ix
        puts "creating file from url"
        create_file_from_url(file)
      elsif file.present?
        puts "creating file"
        create_file_directly(file)
      end
    end

    def create_file_directly(file)
      #file = Tempfile.new(file)
      file = File.new(File.expand_path(file))
      file_name = File.basename(file.path)
      io = ActionDispatch::Http::UploadedFile.new(tempfile: file, filename: file_name)
      #An activerecord model so return nil when record not found
      #file.close
      create_hyrax_uploaded_file(io, file_name)
    end

    def create_file_from_url(file)
      puts "file url #{file}"
      #temp_file = open(file)
      temp_file = create_tempfile_from_url(file)
      file_name = File.basename(file)
      io = ActionDispatch::Http::UploadedFile.new(tempfile: temp_file, filename: file_name)
      temp_file.close
      create_hyrax_uploaded_file(io, file_name)
    end

    def create_tempfile_from_url(file_url)
      data = open(file_url)
      if data.class == StringIO
        create_tempfile_from_stringio(file_url)
      elsif data.class == Tempfile
        #this a  tempfile
         data
      end
    rescue OpenURI::HTTPError => e
      Rails.logger.info "#{e} for this url #{file_url}"
    end

    def create_tempfile_from_stringio(file_url)
      url = file_url
      file_name = url.split('/').last
      file = Tempfile.new(file_name)
      stringIo = open(url)
      file.binmode
      file.write stringIo.read
      file
    end

    def create_hyrax_uploaded_file(file_io, file_name)
      AccountElevator.switch!("#{@tenant_domain}")
      fetch_or_create_file ||= Hyrax::UploadedFile.where(file: file_name).first  || Hyrax::UploadedFile.create(file: file_io, user: @user)
      #@hyrax_uploaded_file = [fetch_or_create_file]
      @hyrax_uploaded_file << fetch_or_create_file
    end

    def attach_files
      AccountElevator.switch!("#{@tenant_domain}")
      #create_file
       create_file_from_array

     #Note that @hyrax_uploaded_file.first.file returns Hyrax::UploadedFileUploader object
     #Also @hyrax_uploaded_file.first.file.file returns a CarrierWave::SanitizedFile object
     #and @hyrax_uploaded_file.first.file.file.filename returns the the filename in carrierwave
     if check_work_has_existing_file_title.present? && @file.present?
       is_file_in_work = check_work_has_existing_file_title.include? @hyrax_uploaded_file.first.file.file.filename
     elsif @file.present?
       is_file_in_work = false
     else
       is_file = nil
     end

     #pass both to AttachFilesToWorkJob
      if @work_instance.present? && @hyrax_uploaded_file.present? && (is_file_in_work != nil) && (is_file_in_work == false)
        $stdout.puts "Attaching files to work"

        AttachFilesToWorkJob.perform_later(@work_instance, @hyrax_uploaded_file)
      end
    end

    def check_work_has_existing_file_title
      if @work_instance.file_sets.present?
        @work_instance.file_sets.map { |file_set| file_set.title.first }
      end
    end

  end
end