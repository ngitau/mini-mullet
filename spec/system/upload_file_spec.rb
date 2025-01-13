describe "upload file" do
  context 'when loaded' do
    it "displays the upload file form" do
      visit new_upload_path

      expect(page).to have_selector('input[type="file"]')
      expect(page).to have_selector('input[type="submit"]')

      expect(page).to have_selector('[data-controller="upload"]')

      expect(page).to have_selector('[data-upload-target="form"]')
      expect(page).to have_selector('[data-upload-target="file"]')
      expect(page).to have_selector('[data-upload-target="info"]')

      expect(page).to have_selector('[data-action="click->upload#upload"]')
    end

    context "when a file is uploaded" do
      skip
    end

    context "when an invalid file is uploaded" do
      skip
    end
  end
end
