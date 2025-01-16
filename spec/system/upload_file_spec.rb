describe "upload file page" do
  context 'loaded' do
    before do
      allow_any_instance_of(UploadsController).to receive(:protect_against_forgery?).and_return(true)
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
      context "without a file" do
        it "notifies the user" do
          click_button 'Upload'

          expect(page).to have_content 'No file selected.'
        end
      end

      context "with a file" do
        context "with a valid file" do
          it "uploads the file and shows success message" do
            attach_file 'upload[file]', Rails.root.join("spec", "fixtures", "valid_file.csv")

            click_button 'Upload'

            expect(page).to have_content 'The file was processed successfully.'
            expect(page).to have_content 'Name'
            expect(page).to have_content 'Password'
            expect(page).to have_content 'Result'
            expect(page).to have_link 'New Upload'
          end
        end

        context "with an invalid file" do
          it "shows an error message" do
            attach_file 'upload[file]', Rails.root.join("spec", "fixtures", "dummy.pdf")

            click_button 'Upload'

            expect(page).not_to have_content 'The file was processed successfully.'
            expect(page).to have_content I18n.t('activemodel.errors.models.upload.attributes.file.must_be_valid_csv_file')
          end
        end

        context "with an empty file" do
          it "shows an error message" do
            attach_file 'upload[file]', Rails.root.join("spec", "fixtures", "empty_file.csv")

            click_button 'Upload'

            expect(page).not_to have_content 'The file was processed successfully.'
            expect(page).to have_content I18n.t('activemodel.errors.models.upload.attributes.file.must_have_data_rows')
          end
        end
      end
    end
  end
end
