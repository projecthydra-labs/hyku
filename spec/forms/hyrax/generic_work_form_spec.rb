# Generated via
#  `rails generate curation_concerns:work GenericWork`
RSpec.describe Hyrax::GenericWorkForm do
  let(:work) {GenericWork.new}
  let(:form) {described_class.new(work, nil, nil)}
  let(:file_set) {FactoryGirl.create(:file_set)}

  describe ".model_attributes" do
    let(:params) {ActionController::Parameters.new(attributes)}
    let(:attributes) do
      {
          title: ['foo'],
          rendering_ids: [file_set.id],
      }
    end

    subject {described_class.model_attributes(params)}

    it 'permits parameters' do
      expect(subject['rendering_ids']).to eq [file_set.id]
    end
  end
end
