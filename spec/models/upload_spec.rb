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
    let(:file) { instance_double("File", read: file_content) }
    let(:upload) { described_class.new(file:, batch_size:) }
    let(:batch_size) { 3 }

    describe '#process_whole' do
      subject { upload.process_whole }

      let(:file_content) { "name,password\nJohnDoe,PFSHH78KSMa\n" }

      context 'when one of the csv rows is valid' do
        it "creates a user and returns a success row" do
          allow(upload).to receive(:csv).and_return(CSV.parse(file_content, headers: true))

          expect(subject.count). to eq 1
          expect(subject.first['result']). to eq "Success"
        end
      end

      context 'when one of the csv rows is invalid' do
        let(:file_content) { "name,password\nJaneDoe,password123\n" }

        it "creates a user and returns a success row" do
          allow(upload).to receive(:csv).and_return(CSV.parse(file_content, headers: true))

          expect(subject.first['result']).not_to eq "Success"
        end
      end
    end

    describe '#process_in_batches' do
      subject { upload.process_in_batches }

      let(:file) { fixture_file_upload(Rails.root.join("spec", "fixtures", "valid_file.csv")) }
      let(:batch_size) { 4 }

      context 'with a valid file' do
        it 'returns a result for every row in the csv' do
          subject

          expect(upload.results.count).to eq upload.csv.count
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

        it 'returns an empty result' do
          subject

          expect(upload.results).to be_empty
        end
      end
    end
  end
end
