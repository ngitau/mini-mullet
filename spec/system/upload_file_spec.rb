describe "upload file" do
  context 'when loaded' do
    it "displays the upload file form" do
      visit new_upload_path

      expect(page).to have_selector('input[type="file"]')
      expect(page).to have_selector('input[type="submit"]')
    end

    context "when a file is uploaded" do
      skip
    end

    context "when an invalid file is uploaded" do
      skip
    end
  end
end
