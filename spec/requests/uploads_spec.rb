describe "/uploads" do
  describe "GET /new" do
    it "renders a successful response" do
      get new_upload_url

      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    file_path = Rails.root.join("spec", "fixtures", "valid_file.csv")
    uploaded_file =  Rack::Test::UploadedFile.new(file_path, "text/csv")

    context "with valid parameters" do
      context 'when a valid file is uploaded' do
        it "creates a new Upload and returns the correct message" do
          post uploads_url, params: { upload: { file: uploaded_file } }, headers: { "Accept" => "text/vnd.turbo-stream.html" }

          expect(response).to have_http_status(:ok)
          expect(response.content_type).to eq("text/vnd.turbo-stream.html; charset=utf-8")
          expect(response.body).to include('<turbo-stream action="replace" target="upload">')
          expect(response.body).to include('<div id="upload-status" data-upload-target="info">')
          expect(response.body).to include('The file was processed successfully.')
        end

        it "creates new user records" do
          expect {
            post uploads_url, params: { upload: { file: uploaded_file } }
          }.to change(User, :count)
        end
      end

      context "when and invalid file is uploaded" do
        invalid_file_path = Rails.root.join("spec", "fixtures", "empty_file.csv")
        invalid_uploaded_file =  Rack::Test::UploadedFile.new(invalid_file_path, "text/csv")

        it "does not create a new Upload and returns the correct message" do
          post uploads_url, params: { upload: { file: invalid_uploaded_file } }, headers: { "Accept" => "text/vnd.turbo-stream.html" }

          expect(response).to have_http_status(:ok)
          expect(response.content_type).to eq("text/vnd.turbo-stream.html; charset=utf-8")
          expect(response.body).to include('<turbo-stream action="replace" target="upload_status">')
          expect(response.body).to include('<div id="upload-status" data-upload-target="info">')
          expect(response.body).to include('Can not process')
        end

        it "does not create new user records" do
          expect {
            post uploads_url, params: { upload: { file: invalid_uploaded_file } }
          }.not_to change(User, :count)
        end
      end
    end

    context "with invalid parameters" do
      context "when parameters include a non file upload[file] value" do
        file = nil

        it "does not create a new Upload and returns the correct message" do
          post uploads_url, params: { upload: { file: } }, headers: { "Accept" => "text/vnd.turbo-stream.html" }

          expect(response).to have_http_status(:ok)
          expect(response.content_type).to eq("text/vnd.turbo-stream.html; charset=utf-8")
          expect(response.body).to include('<turbo-stream action="replace" target="upload_status">')
          expect(response.body).to include('<div id="upload-status" data-upload-target="info">')
          expect(response.body).to include('Can not process')
        end

        it "does not create new user records" do
          expect {
            post uploads_url, params: { upload: { file: } }
          }.not_to change(User, :count)
        end
      end

      context "when upload[file] is not set" do
        it "returns a bad request" do
          post uploads_url

          expect(response).to have_http_status(:bad_request)
        end
      end
    end
  end
end
