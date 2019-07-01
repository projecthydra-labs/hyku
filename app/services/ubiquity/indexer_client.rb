module Ubiquity
  class IndexerClient
    include HTTParty
    base_uri "http://indexer.ubiquity.press"
    attr_reader :api_path, :headers, :resource_type, :work_uuid, :draft_doi, :tenant_name

    def initialize(uuid, draft_doi, tenant_name)
      @resource_type = "repository_work"
      @work_uuid = uuid
      @draft_doi = draft_doi
      @tenant_name = tenant_name
    end

    def post
      service_code = ENV['SERVICE_CODE']
      body = {resource_type: resource_type, uuid: work_uuid, service_code: service_code}.to_json
      handle_client do
        response = self.class.post(api_path, body: body, headers: headers )
        AccountElevator.switch!(tenant_name)
        puts"PICTURE #{draft_doi} - #{ExternalService.find_by(draft_doi: draft_doi)}"
        puts"KITCHEN #{work_uuid} - #{ExternalService.find_by(work_id: work_uuid)}"

        external_service = ExternalService.find_by(draft_doi: draft_doi) || ExternalService.find_by(work_id: work_uuid)
        external_service.try(:data)['status_code'] = response.code
        external_service.save
        set_official_url(work_uuid, response.code)
        response
      end
    end

    private

    def api_path
      '/api/entry/'
    end

    def handle_client
      begin
        yield
      rescue HTTParty::Error => e
        puts "Nothing pushed to indexer #{e.inspect}"
      end
    end

    def headers
      {
         'Content-Type' => 'application/json',
         'Authorization' => "Token #{ENV['INDEXER_API_TOKEN']}"
        }

    end

    def set_official_url(id, status_code)
      work = ActiveFedora::Base.find(id)
      if [201, 200].include? status_code
        #work.update(official_link: "https://doi.org/#{work.draft_doi}") if work.official_link.blank?
         if work.official_link.blank?
          work.official_link = "https://doi.org/#{work.draft_doi}"
          puts"TAKEAWAY #{work.official_link_changed?}"
          work.save
        end
      end
    end


  end
end
