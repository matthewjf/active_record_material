class User < Model
  attr_accessor :fname, :lname

  def self.find_by_name(fname, lname)
    User.new(QuestionsDBConnection.instance.execute(<<-SQL, fname: fname, lname: lname).first)
      SELECT
        *
      FROM
        users
      WHERE
        fname = :fname AND lname = :lname
    SQL
  end

  def create
    raise "User already in database" if @id
    QuestionsDBConnection.instance.execute(<<-SQL, @fname, @lname)
      INSERT INTO
        users (fname, lname)
      VALUES
        (?,?)
    SQL
    @id = QuestionsDBConnection.instance.last_insert_row_id
  end

  def update
    raise "No user in database" unless @id
    QuestionsDBConnection.instance.execute(<<-SQL, id: @id, fname: @fname, lname: @lname)
      UPDATE
        users
      SET
        fname = :fname, lname = :lname
      WHERE
        id = :id
    SQL
  end

  def authored_questions
    questions = QuestionsDBConnection.instance.execute(<<-SQL, @id)
      SELECT
        *
      FROM
        questions
      WHERE
        questions.author_id = ?
    SQL
    questions.map { |question| Question.new(question) }
  end

  def authored_replies
    questions = QuestionsDBConnection.instance.execute(<<-SQL, @id)
      SELECT
        *
      FROM
        replies
      WHERE
        replies.author_id = ?
    SQL
    questions.map { |question| Question.new(question) }
  end

  def followed_questions
    QuestionFollow.followed_questions_for_user_id(@id)
  end

  def liked_questions
    QuestionLike.liked_questions_for_user_id(@id)
  end

  def average_karma
    karma_hash = QuestionsDBConnection.instance.execute(<<-SQL, @id)
      SELECT
        u.id, AVG(count) AS average
      FROM
        users AS u
        Join (
          SELECT
            questions.*, count(*) AS count
          FROM
            questions
            JOIN question_likes AS likes
              ON questions.id = likes.question_id
          GROUP BY
            questions.id
          ) AS like_per_question
            ON u.id = like_per_question.author_id
      WHERE
        u.id = ?
      GROUP BY
        author_id
    SQL
    karma_hash.first["average"]
  end
end
