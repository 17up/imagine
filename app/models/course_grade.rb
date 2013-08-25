class CourseGrade
  include Mongoid::Document
  include Mongoid::Timestamps::Short
  
  field :course_id
  field :grade, type: Integer

  embedded_in :member
end