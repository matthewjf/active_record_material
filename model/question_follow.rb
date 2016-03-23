class QuestionFollow < Model
  attr_reader :user_id, :question_id

  def create
    raise "already following" if @id
    QuestionsDBConnection.instance.execute(<<-SQL, @question_id, @user_id)
      INSERT INTO
        replies (question_id, user_id)
      VALUES
        (?, ?)
    SQL
    @id = QuestionsDBConnection.instance.last_insert_row_id
  end

  def self.followers_for_question_id(question_id)
    users = QuestionsDBConnection.instance.execute(<<-SQL, question_id)
    SELECT
      users.*
    FROM
      question_follows
      JOIN users
        ON users.id = question_follows.user_id
    WHERE
      question_id = ?
    SQL
    users.map do |user_hash|
      User.new(user_hash)
    end
  end

  def self.followed_questions_for_user_id(user_id)
    questions = QuestionsDBConnection.instance.execute(<<-SQL, user_id)
    SELECT
      questions.*
    FROM
      question_follows
      JOIN questions
        ON questions.id = question_follows.question_id
    WHERE
      user_id = ?
    SQL
    questions.map do |q_hash|
      Question.new(q_hash)
    end
  end

  def self.most_followed_questions(n)
    questions = QuestionsDBConnection.instance.execute(<<-SQL,n)
      SELECT
        questions.*
      FROM
        questions
        JOIN question_follows AS follows
          ON questions.id = follows.question_id
      GROUP BY
        questions.id
      ORDER BY
        COUNT(follows.user_id) DESC
      LIMIT
        ?
    SQL

    questions.map do |q_hash|
      Question.new(q_hash)
    end
  end
end
