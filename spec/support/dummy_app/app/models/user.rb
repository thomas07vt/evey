class User < ApplicationRecord
  belongs_to :org, optional: true
end
