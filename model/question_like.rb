class QuestionLike < Model
  attr_reader :question_id, :user_id

  def self.likers_for_question_id(question_id)
    likers = QuestionsDBConnection.instance.execute(<<-SQL, question_id)
    SELECT
      users.*
    FROM
      question_likes
      JOIN users
        ON users.id = question_likes.user_id
    WHERE
      question_id = ?
    SQL
    likers.map do |liker_hash|
      User.new(liker_hash)
    end
  end

  def self.num_likers_for_question_id(question_id)
    num_likers = QuestionsDBConnection.instance.execute(<<-SQL, question_id)
    SELECT
      COUNT(*) AS num
    FROM
      question_likes
      JOIN users
        ON users.id = question_likes.user_id
    WHERE
      question_id = ?
    SQL

    num_likers.first['num']
  end

  def self.liked_questions_for_user_id(user_id)
    questions = QuestionsDBConnection.instance.execute(<<-SQL, user_id)
    SELECT
      questions.*
    FROM
      question_likes
      JOIN questions
        ON questions.id = question_likes.question_id
    WHERE
      user_id = ?
    SQL
    questions.map do |q_hash|
      Question.new(q_hash)
    end
  end

  def create
    raise "Like already in database" if @id
    QuestionsDBConnection.instance.execute(<<-SQL, @question_id, @user_id)
      INSERT INTO
        replies (question_id, user_id)
      VALUES
        (?, ?)
    SQL
    @id = QuestionsDBConnection.instance.last_insert_row_id
  end

  def self.most_liked_questions(n)
    questions = QuestionsDBConnection.instance.execute(<<-SQL,n)
      SELECT
        questions.*
      FROM
        questions
        JOIN question_likes AS likes
          ON questions.id = likes.question_id
      GROUP BY
        questions.id
      ORDER BY
        COUNT(likes.user_id) DESC
      LIMIT
        ?
    SQL

    questions.map do |q_hash|
      Question.new(q_hash)
    end
  end
end
