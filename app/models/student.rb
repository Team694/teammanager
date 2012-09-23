class Student < ActiveRecord::Base
  attr_accessible :father_name, :first_name, :last_name, :mother_name, :parent_cell_phone, :parent_email, :parent_home_phone, :preferred_language, :student_cell_phone, :student_email, :student_id, :year
  has_many :medical_forms
  has_many :safety_tests
  has_many :parent_permission_forms
  has_many :teacher_permission_forms
  has_many :p_trips, through: :parent_permission_forms, source: :trip
  has_many :t_trips, through: :teacher_permission_forms, source: :trip
  validates :first_name, presence: true
  validates :last_name, presence: true

  before_save :remove_non_digits_from_phone_number

  def full_name
    "#{self.first_name} #{self.last_name}"
  end

  def has_valid_medical_on date
    (self.medical_forms.where 'date > ?', date - 1.year).length > 0
  end

  def passed_safety_test?
    if Date.today.month < 9
      (self.safety_tests.where 'date > ?', (Date.new Date.today.year - 1, 9, 1)).length > 0
    else
      (self.safety_tests.where 'date > ?', (Date.new Date.today.year, 9, 1)).length > 0
    end
  end

  def remove_non_digits_from_phone_number
    student_cell_phone.gsub! /\D/, ''
    parent_home_phone.gsub! /\D/, ''
    parent_cell_phone.gsub! /\D/, ''
  end

  def all_trips
    (self.p_trips + self.t_trips).sort { |a, b| b.date <=> a.date } # Sort by date descending
  end

  def has_parent_permission_form_for trip
    self.parent_permission_forms.where(trip_id: trip.id).count > 0
  end

  def has_teacher_permission_form_for trip
    self.teacher_permission_forms.where(trip_id: trip.id).count > 0
  end

  def can_attend_trip trip
    self.has_parent_permission_form_for trip \
    and (!trip.requires_teacher_permission_form or self.has_teacher_permission_form_for trip) \
    and (!trip.requires_medical_form or self.has_valid_medical_on trip.end_date)
  end
end
