FactoryBot.define do
  factory :user do
    name { "John" }
    sequence(:email) { |n| "user.#{n}@example.com" }
    org_id {}
  end
end
