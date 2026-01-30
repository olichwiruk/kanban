class Comment < ApplicationRecord
  belongs_to :card, counter_cache: true
  belongs_to :author, class_name: "User"
end
