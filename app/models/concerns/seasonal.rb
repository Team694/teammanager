# Seasonal documents expire at the beginning of a new school year.
#
# Safety tests, team dues, and media consent forms are examples of seasonal
# documents that are invalidated at the beginning of a new school year.
#
# The `year` field for Seasonals describes the last year the form is valid. An
# easy way to remember this is that the year is the same as the FRC season for
# that school year.
# Ex.: A safety test with year 2015 is valid for the 2014-2015 school year.
# Ex.: A team due with year 2016 is valid for the 2015-2016 school year.
module Seasonal
  extend ActiveSupport::Concern

  included do
    belongs_to :student

    validates :year, :student_id, presence: true
    before_validation :set_current_year

    scope :valid_for, -> (year) { where(year: year) }

    scope :valid, -> { valid_for(current_year) }
  end

  def set_current_year
    self.year ||= self.class.current_year
  end

  module ClassMethods
    def current_year
      if Time.now.month < 9
        Time.now.year
      else
        Time.now.year + 1
      end
    end
  end
end