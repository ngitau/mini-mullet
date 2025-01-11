describe Upload do
  describe "validations" do
    subject { Upload.new(file:) }

    context 'with file provided' do
      let(:file) { fixture_file_upload(Rails.root.join("spec", "fixtures", "#{file_name}")) }
      context 'when a valid file is provided' do
        let(:file_name) { 'valid_file.csv' }

        it { is_expected.to be_valid }
      end

      context 'when a file without rows is provided' do
        let(:file_name) { 'empty_file.csv' }

        it 'is not valid and bears the correct error message' do
          error_message = I18n.t('activemodel.errors.models.upload.attributes.file.must_have_data_rows')

          expect(subject).not_to be_valid
          expect(subject.errors[:file]).to include(error_message)
        end
      end

      context 'when an invalid file type is provided' do
        let(:file_name) { 'dummy.pdf' }

        it 'is not valid and bears the correct error message' do
          error_message = I18n.t('activemodel.errors.models.upload.attributes.file.must_be_valid_csv_file')

          expect(subject).not_to be_valid
          expect(subject.errors[:file]).to include(error_message)
        end
      end
    end

    context 'with no file' do
      let(:file) { nil }

      it { is_expected.not_to be_valid }
    end
  end
end
