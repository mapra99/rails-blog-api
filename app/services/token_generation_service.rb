# frozen_string_literal: true

class TokenGenerationService
  def self.generate
    SecureRandom.hex
  end
end
