require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

RSpec.describe SitesController, type: :controller do
  before do
    sign_in user
  end

  # This should return the minimal set of attributes required to create a valid
  # Site. As you add validations to Site, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) do
    {
      application_name: "Custom Name",
      institution_name: "Custom Inst Name"
    }
  end

  let(:invalid_attributes) do
    { application_name: "" }
  end

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # SitesController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  context 'with an unprivileged user' do
    let(:user) { FactoryGirl.create(:user) }

    describe "GET #edit" do
      it "denies the request" do
        get :edit, {}
        expect(response).to have_http_status(401)
      end
    end

    describe "PUT #update" do
      it "denies the request" do
        put :update, {}
        expect(response).to have_http_status(401)
      end
    end
  end

  context 'with an administrator' do
    let(:user) { FactoryGirl.create(:admin) }

    describe "GET #edit" do
      it "assigns the requested site as @site" do
        get :edit, {}, valid_session
        expect(assigns(:site)).to eq(Site.instance)
      end
    end

    describe "PUT #update" do
      context "with valid params" do
        let(:new_attributes) do
          {
            application_name: "New Custom Name",
            institution_name: "New Custom Inst Name"
          }
        end

        it "updates the requested site" do
          put :update, { site: new_attributes }, valid_session
          Site.reload
          expect(Site.application_name).to eq "New Custom Name"
          expect(Site.institution_name).to eq "New Custom Inst Name"
        end

        it "assigns the requested site as @site" do
          put :update, { site: valid_attributes }, valid_session
          expect(assigns(:site)).to eq(Site.instance)
        end

        it "redirects to the site" do
          put :update, { site: valid_attributes }, valid_session
          expect(response).to redirect_to(edit_site_path)
        end
      end

      context "with invalid params" do
        it "assigns the site as @site" do
          put :update, { site: invalid_attributes }, valid_session
          expect(assigns(:site)).to eq(Site.instance)
        end

        it "re-renders the 'edit' template" do
          put :update, { site: invalid_attributes }, valid_session
          expect(response).to render_template("edit")
        end
      end
    end
  end
end
