module Ubiquity
  module BasicMetadataDecorator
    extend ActiveSupport::Concern
    # include here properties (fields) shared across all templates
    # also see SharedMetadata
    included do
      property :institution, predicate: ::RDF::Vocab::ORG.organization do |index|
        index.as :stored_searchable
      end
      property :org_unit, predicate: ::RDF::Vocab::ORG.OrganizationalUnit do |index|
        index.as :stored_searchable
      end
      property :refereed, predicate: ::RDF::Vocab::BIBO.term("status/peerReviewed") do |index|
        index.as :stored_searchable
      end
      property :funder, predicate: ::RDF::Vocab::MARCRelators.fnd do |index|
        index.as :stored_searchable
      end
      property :fndr_project_ref, predicate: ::RDF::Vocab::BF2.awards do |index|
        index.as :stored_searchable
      end
      property :add_info, predicate: ::RDF::Vocab::BIBO.term(:Note) do |index|
        index.as :stored_searchable
      end
      property :date_published, predicate: ::RDF::Vocab::DC.available do |index|
        index.as :stored_searchable
      end
      property :date_accepted, predicate: ::RDF::Vocab::DC.dateAccepted do |index|
        index.as :stored_searchable
      end
      property :date_submitted, predicate: ::RDF::Vocab::DC.dateSubmitted do |index|
        index.as :stored_searchable
      end
      property :project_name, predicate: ::RDF::Vocab::BF2.term(:CollectiveTitle) do |index|
        index.as :stored_searchable
      end
      property :rights_holder, predicate: ::RDF::Vocab::DC.rightsHolder, multiple: false do |index|
        index.as :stored_searchable
      end
      property :doi, predicate: ::RDF::Vocab::BIBO.doi, multiple: false do |index|
        index.as :stored_searchable
      end

      property :creator_name_type, predicate: ::RDF::Vocab::DC11.type do |index|
        index.as :stored_searchable
      end

      property :given_name, predicate: ::RDF::Vocab::FOAF.givenName, multiple: false do |index|
        index.as :stored_searchable
      end

      property :family_name, predicate: ::RDF::Vocab::FOAF.family_name do |index|
        index.as :stored_searchable
      end

      property :ORCiD, predicate: ::RDF::Vocab::DataCite.orcid do |index|
        index.as :stored_searchable
      end

      property :isni, predicate: ::RDF::Vocab::DataCite.isni do |index|
        index.as :stored_searchable
      end

      property :creator_organization, predicate: :: RDF::Vocab::FOAF.Organization, multiple: false do |index|
        index.as :stored_searchable
      end

    end
  end
end