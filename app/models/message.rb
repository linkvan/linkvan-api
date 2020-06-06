class Message

  include ActiveModel::Model
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attr_accessor :name, :phone, :content

  validates :name,
    presence: true

  validates :phone,
    presence: true

  validates :content,
    presence: true



end