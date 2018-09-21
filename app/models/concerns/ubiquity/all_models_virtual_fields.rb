module Ubiquity
  module AllModelsVirtualFields
    extend ActiveSupport::Concern

    included do

      before_save :save_contributor
      before_save :save_creator
      before_save :save_alternate_identifier
      before_save :save_related_identifier

      attr_accessor :contributor_group, :contributor_name_type, :contributor_type, :contributor_given_name,
                    :contributor_family_name, :contributor_orcid, :contributor_isni,
                    :contributor_position, :contributor_organization_name

      attr_accessor :creator_group, :creator_name_type, :creator_organization_name, :creator_given_name,
                    :creator_family_name, :creator_orcid, :creator_isni,
                    :creator_position

      attr_accessor :alternate_identifier_group, :related_identifier_group

    end

    private

    # remove hash keys with value of nil, "", and "NaN"
    def remove_hash_keys_with_empty_and_nil_values(data)
      data.map do |hash|
        h = hash.reject { |k,v| v.nil? || v.to_s.empty? || v == "NaN" }
        h.present? ? clean_position(h) : h
      end
    end

    def clean_position(hash)
      k = hash.keys
      return {} if k.first.include?("position")
      hash
    end

    def save_creator
      new_creator_group = remove_hash_keys_with_empty_and_nil_values(self.creator_group)
      creator_json = new_creator_group.to_json
      self.creator = [creator_json]
    end

    def save_contributor
      new_contributor_group = remove_hash_keys_with_empty_and_nil_values(self.contributor_group)
      contributor_json = new_contributor_group.to_json
      self.contributor = [contributor_json]
    end

    def save_alternate_identifier
      if self.alternate_identifier_group.present?
        new_alternate_identifier_group = remove_hash_keys_with_empty_and_nil_values(self.alternate_identifier_group)
        alternate_identifier_json = new_alternate_identifier_group.to_json
        self.alternate_identifier = [alternate_identifier_json]
      end
    end

    def save_related_identifier
      if self.related_identifier_group.present?
        new_related_identifier_group = remove_hash_keys_with_empty_and_nil_values(self.related_identifier_group)
        related_identifier_json = new_related_identifier_group.to_json
        self.related_identifier = [related_identifier_json]
      end
     end
  end
end
