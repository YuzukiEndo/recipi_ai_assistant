require 'rails_helper'

RSpec.describe "RecipeConditions", type: :request do
  describe "GET /new" do
    it "returns http success" do
      get "/recipe_conditions/new"
      expect(response).to have_http_status(:success)
    end
  end

end
