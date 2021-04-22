class Org < ApplicationRecord
  belongs_to :owner, class_name: :User, optional: true
  has_many :users

  validates :name, presence: true
end
