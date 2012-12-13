class MedicalForm < ActiveRecord::Base
  attr_accessible :date
  belongs_to :student
  validates :date, presence: true

  def is_valid?
    self.date > 1.year.ago.to_date
  end
end
