# Generated via
#  `rails generate hyrax:work Book`
module Hyrax
  class BookForm < Hyrax::Forms::WorkForm
    include Hyrax::FormTerms
    self.model_class = ::Book
    self.terms += [:resource_type]
  end
end
