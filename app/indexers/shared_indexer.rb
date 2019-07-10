class SharedIndexer < Hyrax::WorkIndexer
  # Use thumbnails served by RIIIF
  self.thumbnail_path_service = IIIFWorkThumbnailPathService

  def generate_solr_document
    super.tap do |solr_doc|
      solr_doc[Solrizer.solr_name('contributor_list', :stored_searchable)] = Ubiquity::ParseJson.new(object.contributor.first).fetch_value_based_on_key('contributor')
    end
  end
end
