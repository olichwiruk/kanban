class Comment < ApplicationRecord
  belongs_to :card
  belongs_to :author, class_name: "User"
end
