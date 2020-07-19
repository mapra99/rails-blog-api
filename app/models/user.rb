# frozen_string_literal: true

class User < ApplicationRecord
  has_many :posts

  validates :email, presence: true
  validates :name, presence: true
  validates :auth_token, presence: true

  after_initialize :generate_auth_token

  def generate_auth_token
    return if auth_token.present?

    self.auth_token = TokenGenerationService.generate
  end
end
