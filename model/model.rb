require_relative 'questions_database'
require 'byebug'

class Model

  CLASS_NAMES = {
    "User" => 'users',
    "Reply" => 'replies',
    "Question" => 'questions',
    "QuestionLike" => 'question_likes',
    "QuestionFollow" => 'question_follows'
  }

  def initialize(options)
    options.each { |k,v| set(k,v) }
  end

  def set(key, value)
    instance_key = "@#{key}"
    self.instance_variable_set(instance_key, value)
  end

  def self.all
    data = QuestionsDBConnection.instance.execute("SELECT * FROM #{CLASS_NAMES[self.to_s]};")
    data.map { |datum| self.new(datum) }
  end

  def self.find_by_id(id)
    self.new(QuestionsDBConnection.instance.execute(<<-SQL, find_id: id).first)
      SELECT
        *
      FROM
        #{CLASS_NAMES[self.to_s]}
      WHERE
        id = :find_id
    SQL
  end

  # def execute(query, *args)
  #   QuestionsDBConnection.instance.execute(query, *args)
  # end
end
