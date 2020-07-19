# frozen_string_literal: true

FactoryBot.define do
  factory :post do
    title { Faker::Lorem.sentence }
    content { Faker::Lorem.paragraph }
    published { rand(0..1) == 1 }
    user
  end
end
