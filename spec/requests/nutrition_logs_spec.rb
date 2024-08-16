require 'rails_helper'

RSpec.describe "NutritionLogs", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/nutrition_logs/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/nutrition_logs/create"
      expect(response).to have_http_status(:success)
    end
  end

end
