class Tweet
  include ActiveModel::Model

  attr_accessor :user, :content, :id
end
