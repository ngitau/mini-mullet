describe Upload do
  describe "validations" do
    subject { Upload.new(file:) }

    context 'with file provided' do
      let(:file) { fixture_file_upload(Rails.root.join("spec", "fixtures", "#{file_name}")) }
      let(:file_name) { 'valid_file.csv' }

      context 'when a valid file is provided' do
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

      context 'when a file is missing required headers' do
        let(:file) { instance_double("File", path: file_path, read: file_content, size: 10) }
        let(:file_path) { fixture_file_upload(Rails.root.join("spec", "fixtures", "empty_file.csv")) }
        let(:file_content) { "JohnDoe,secret\nJaneDoe,password123\n" }

        it 'is not valid and bears the correct error message' do
          allow(file).to receive(:open).with(file_path, 'r').and_return [ "name,password\n" ]

          error_message = I18n.t('activemodel.errors.models.upload.attributes.file.must_have_required_headers')

          expect(subject).not_to be_valid
          expect(subject.errors[:file]).to include(error_message)
        end
      end

      context 'when a file has an invalid delimiter' do
        let(:file_name) { 'invalid_delimiter.csv' }
        let(:col_sep) { ',' }

        it 'is not valid and bears the correct error message' do
          # skip 'Flaky'

          error_message = I18n.t('activemodel.errors.models.upload.attributes.file.must_use_valid_delimiter', col_sep:)

          expect(subject).not_to be_valid
          expect(subject.errors[:file]).to include(error_message)
        end
      end

      context 'when file size is greater than limit' do
        it 'is not valid and bears the correct error message' do
          allow(file).to receive(:size).and_return(11*(1024**2))

          error_message = I18n.t('activemodel.errors.models.upload.attributes.file.must_be_within_size_limit')

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
    let(:file_content) { "name,password\nJohnDoe,secret\nJaneDoe,password123\n" }
    let(:file) { instance_double("File", read: file_content) }
    let(:upload) { described_class.new(file:, batch_size:) }
    let(:batch_size) { 3 }

    describe "#save" do
      subject(:save) { upload.save }

      context 'when upload is valid' do
        it "calls #process" do
          allow(upload).to receive(:valid?).and_return true
          allow(upload).to receive(:process).and_return true

          expect(upload).to receive(:process).once

          save
        end
      end

      context 'when upload is not valid' do
        it "calls #process" do
          allow(upload).to receive(:valid?).and_return false

          expect(upload).not_to receive(:process)

          save
        end
      end

    end

    describe '#process' do
      subject { upload.process }

      context "when rows are fewer than the batch size" do
        it "calls .process_whole" do
          allow(upload).to receive(:csv).and_return(CSV.parse(file_content, headers: true))
          allow(upload).to receive(:process_whole).and_return true

          expect(upload).to receive(:process_whole).once

          subject
        end
      end

      context "when rows are more than the batch size" do
        let(:file_content) { "name,password\n" + Array.new(5) { "JohnDoe,secret" }.join("\n") }

        it "calls .update_file and .process_in_batches" do
          allow(upload).to receive(:csv).and_return(CSV.parse(file_content, headers: true))
          allow(upload).to receive(:update_file).and_return true
          allow(upload).to receive(:process_in_batches).and_return true

          expect(upload).to receive(:update_file).once
          expect(upload).to receive(:process_in_batches).once

          subject
        end
      end
    end

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
          allow(User).to receive(:create_from_collection).and_return []

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

    describe "#update_file" do
      let(:file) { instance_double("File",  path: file_path, read: file_content, write: nil) }
      let(:file_path) { fixture_file_upload(Rails.root.join("spec", "fixtures", "empty_file.csv")) }
      let(:file_content) { "name,password\nJohnDoe,secret\nJaneDoe,password123\n" }
      let(:normalized_content) { "name,password\nJohnDoe,secret\nJaneDoe,password123\n" }

      before do
        allow(upload).to receive(:normalized_str).and_return(normalized_content)
      end

      context "when file contents are not substituted" do
        it "does not write to the file" do
          allow(upload).to receive(:contents).and_return(normalized_content)

          expect(file).not_to receive(:write)

          upload.update_file
        end
      end

      context "when file contents are substituted" do
        let(:invalid_content) { "name,password\r\nJohnDoe,secret\r\nJaneDoe,password123\r\n" }

        before do
          allow(upload).to receive(:contents).and_return(invalid_content)
        end

        it "opens the file in write mode and writes the updated content" do
          expect(File).to receive(:open).with(file_path, "w").and_yield(file_instance = double("File"))
          expect(file_instance).to receive(:write).with(normalized_content)

          upload.update_file
        end
      end
    end
  end
end
