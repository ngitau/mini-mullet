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

  describe 'methods' do
    describe '.process_in_batches' do
      subject { upload.process_in_batches(batch_size) }

      let(:file) { fixture_file_upload(Rails.root.join("spec", "fixtures", "valid_file.csv")) }
      let(:upload) { Upload.new(file:) }
      let(:batch_size) { 4 }

      context 'with a valid file' do
        it 'returns a result for every row in the csv' do
          expect(subject.count).to eq upload.csv.count
        end

        it 'attempts to create users in batches' do
          allow(User).to receive(:create_from_collection)

          subject

          expect(User).to have_received(:create_from_collection).exactly(2).times
        end
      end

      context 'with an invalid file' do
        let(:file) { fixture_file_upload(Rails.root.join("spec", "fixtures", "dummy.pdf")) }

        it { is_expected.to be_falsey }
      end
    end
  end
end
