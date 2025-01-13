describe User do
  describe 'validations' do
    subject { User.new(name:, password:) }

    context 'with valid attributes' do
      let(:name) { 'John' }
      let(:password) { 'Aqpfk1swods' }

      it { is_expected.to be_valid }
    end

    context 'with missing attributes' do
      let(:name) { '' }
      let(:password) { '' }

      context 'when name and password are not provided' do
        it { is_expected.not_to be_valid }
      end

      context 'when a name is not provided' do
        let(:password) { 'password' }

        it { is_expected.not_to be_valid }
      end

      context 'when a password is not provided' do
        let(:name) { 'John' }

        it { is_expected.not_to be_valid }

        it 'does not run any password complexity validations' do
          too_short_error = "is too short (minimum is 10 characters)"
          must_have_digit_error = I18n.t('activerecord.errors.models.user.attributes.password.must_have_digit')

          expect(subject).not_to be_valid

          expect(subject.errors[:password]).not_to include too_short_error
          expect(subject.errors[:password]).not_to include must_have_digit_error
        end
      end
    end

    context 'with an invalid password' do
      let(:name) { 'John' }

      context 'when the password is too short' do
        let(:password) { 'Abc123' }

        it 'is not valid and bears the correct error message' do
          error_message = "is too short (minimum is 10 characters)"

          expect(subject).not_to be_valid
          expect(subject.errors[:password]).to include error_message
        end
      end

      context 'when the password is too long' do
        let(:password) { 'Abc123qwertyuiop.' }

        it 'is not valid and bears the correct error message' do
          error_message = "is too long (maximum is 16 characters)"

          expect(subject).not_to be_valid
          expect(subject.errors[:password]).to include error_message
        end
      end

      context 'when the password does not contain an uppercase character' do
        let(:password) { 'abcdefghijklmnop' }

        it 'is not valid and bears the correct error message' do
          error_message = I18n.t('activerecord.errors.models.user.attributes.password.must_have_uppercase_char')

          expect(subject).not_to be_valid
          expect(subject.errors[:password]).to include error_message
        end
      end

      context 'when the password does not contain an lowercase character' do
        let(:password) { 'QWERTYUIOP' }

        it 'is not valid and bears the correct error message' do
          error_message = I18n.t('activerecord.errors.models.user.attributes.password.must_have_lowercase_char')

          expect(subject).not_to be_valid
          expect(subject.errors[:password]).to include error_message
        end
      end

      context 'when the password does not contain an a digit' do
        let(:password) { '@bcdefghijklmnop' }

        it 'is not valid and bears the correct error message' do
          error_message = I18n.t('activerecord.errors.models.user.attributes.password.must_have_digit')

          expect(subject).not_to be_valid
          expect(subject.errors[:password]).to include error_message
        end
      end

      context 'when the password contains three repeating characters' do
        let(:password) { 'AAAfk1swods' }

        it 'is not valid and bears the correct error message' do
          error_message = I18n.t('activerecord.errors.models.user.attributes.password.must_not_have_3_repeating_chars')

          expect(subject).not_to be_valid
          expect(subject.errors[:password]).to include error_message
        end
      end

      context 'when the password validation fails multiple complexity checks' do
        let(:password) { 'aafklswodsa' }

        it 'is not valid and bears the correct error messages' do
          error_messages = [
            I18n.t('activerecord.errors.models.user.attributes.password.must_have_digit'),
            I18n.t('activerecord.errors.models.user.attributes.password.must_have_uppercase_char')
          ]

          expect(subject).not_to be_valid
          expect(subject.errors[:password]).to eq error_messages
        end
      end
    end
  end

  describe 'normalizations' do
    context 'when name is provided with leading or trailing whitespaces' do
      it 'trims whitespaces' do
        name = '  John '
        user = User.create!(name:, password: 'PFSHH78KSMa')

        expect(user.name).to eq name.strip
      end
    end
  end

  describe 'methods' do
    describe '.create_from_rows' do
      subject { User.create_from_collection(rows, []) }
      let(:rows) { [] }

      context 'when one of the rows has the required data' do
        before do
          rows << { name: 'John', password: 'PFSHH78KSMa' }.with_indifferent_access
        end

        it 'returns a result hash with validity attributes' do
          expect(subject.count).to eq rows.count
          expect(subject.first['valid?']).to be_truthy
          expect(subject.first['result']).to eq 'Success'
        end

        it 'create a user' do
          expect { subject }.to change(User, :count).by 1
        end
      end

      context 'when a row is missing some data' do
        before do
          rows << { name: 'John' }.with_indifferent_access
        end

        it 'returns a result hash with validity attributes' do
          expect(subject.count).to eq rows.count

          expect(subject.first['valid?']).to be_falsey
          expect(subject.first['result']).not_to eq 'Success'
        end

        it 'does not create any records' do
          expect { subject }.not_to change(User, :count)
        end
      end

      context 'when all of the rows are empty' do
        it 'does not create any records' do
          expect { subject }.not_to change(User, :count)
        end
      end
    end
  end
end
