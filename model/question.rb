class Question < Model
  attr_accessor :title, :body
  attr_reader :author_id

  def self.find_by_author_id(author_id)
    questions = QuestionsDBConnection.instance.execute(<<-SQL, author_id)
      SELECT
        *
      FROM
        questions
      WHERE
        author_id = ?
    SQL
    questions.map { |question| Question.new(question) }
  end

  def self.most_followed(n)
    QuestionFollow.most_followed_questions(n)
  end

  def self.most_liked(n)
    QuestionLike.most_liked_questions(n)
  end

  def create
    raise 'question already exists' if @id
    QuestionsDBConnection.instance.execute(<<-SQL, @title, @body, @author_id)
      INSERT INTO
        questions (title, body, author_id)
      VALUES
        (?,?,?)
    SQL
    @id = QuestionsDBConnection.instance.last_insert_row_id
  end

  def update
    raise "No question in database" unless @id
    QuestionsDBConnection.instance.execute(<<-SQL, id: @id, title: @title, body: @body)
      UPDATE
        questions
      SET
        title = :title, body = :body
      WHERE
        id = :id
    SQL
  end

  def author
    User.find_by_id(@author_id)
  end

  def replies
    Reply.find_by_question_id(@id)
  end

  def followers
    QuestionFollow.followers_for_question_id(@id)
  end

  def likers
    QuestionLike.likers_for_question_id(@id)
  end

  def num_likes
    QuestionLike.num_likers_for_question_id(@id)
  end

end
