describe UploadsController do
  describe "routing" do
    it "routes to #new" do
      expect(get: "/uploads/new").to route_to("uploads#new")
    end

    it "routes to #create" do
      expect(post: "/uploads").to route_to("uploads#create")
    end
  end
end
