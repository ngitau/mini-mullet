describe "upload file page" do
  context 'loaded' do
    before do
      visit new_upload_path
    end

    it "displays the upload file form" do
      expect(page).to have_selector('input[type="file"]')
      expect(page).to have_selector('input[type="submit"]')

      expect(page).to have_selector('[data-controller="upload"]')

      expect(page).to have_selector('[data-upload-target="form"]')
      expect(page).to have_selector('[data-upload-target="file"]')
      expect(page).to have_selector('[data-upload-target="info"]')

      expect(page).to have_selector('[data-action="click->upload#upload"]')
    end

    context 'when form is submitted' do
      context "with no file was chosen" do
        it "notifies the user" do
          click_button 'Upload'

          expect(page).to have_content 'No file selected.'
        end
      end

      context "when a file is provided" do
        context "with a valid file" do
          it "uploads the file and shows success message" do
            skip "AJAX request not getting triggered"

            attach_file 'upload[file]', Rails.root.join("spec", "fixtures", "valid_file.csv")

            click_button 'Upload'

            expect(page).to have_content 'The file was processed successfully.'
          end
        end

        context "with an invalid file" do
          skip "AJAX request not getting triggered"
        end
      end
    end
  end
end
