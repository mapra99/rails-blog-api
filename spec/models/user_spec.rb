# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it 'validates presence of required fields' do
      should validate_presence_of(:email)
      should validate_presence_of(:name)
      should validate_presence_of(:auth_token)
    end
  end

  describe 'associations' do
    it 'validates relations' do
      should have_many(:posts)
    end
  end
end
