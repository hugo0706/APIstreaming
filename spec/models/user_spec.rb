require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it 'is valid with a unique email' do
      user = User.new(email: 'user@mail.com')
      expect(user).to be_valid
    end

    it 'is not valid without an email' do
      user = User.new(email: nil)
      expect(user).to_not be_valid
    end

    it 'is not valid with a repeated email' do
      User.create!(email: 'user@mail.com')
      user = User.new(email: 'user@mail.com')
      expect(user).to_not be_valid
    end
  end

end
