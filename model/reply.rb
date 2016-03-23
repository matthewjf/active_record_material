class Reply < Model
  attr_accessor :body
  attr_reader :question_id, :reply_id, :author_id

  def self.find_by_user_id(author_id)
    replies = QuestionsDBConnection.instance.execute(<<-SQL, author_id)
      SELECT
        *
      FROM
        replies
      WHERE
        author_id = ?
    SQL
    replies.map { |reply| Reply.new(reply) }
  end

  def self.find_by_question_id(question_id)
    replies = QuestionsDBConnection.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        replies
      WHERE
        question_id = ?
    SQL
    replies.map { |reply| Reply.new(reply) }
  end

  def create
    raise "Reply already in database" if @id
    QuestionsDBConnection.instance.execute(<<-SQL, @question_id, @reply_id, @author_id, @body)
      INSERT INTO
        replies (question_id, reply_id, author_id, body)
      VALUES
        (?, ?, ?, ?)
    SQL
    @id = QuestionsDBConnection.instance.last_insert_row_id
  end

  def update
    raise "No reply in database" unless @id
    QuestionsDBConnection.instance.execute(<<-SQL, id: @id, body: @body)
      UPDATE
        users
      SET
        body = :body
      WHERE
        id = :id
    SQL
  end

  def author
    User.find_by_id(@author_id)
  end

  def parent_reply
    if @reply_id
      Reply.find_by_id(@reply_id)
    else
      Question.find_by_id(@question_id)
    end
  end

  def child_replies
    children = QuestionsDBConnection.instance.execute(<<-SQL, parent_id: @id)
      SELECT
        *
      FROM
        replies
      WHERE
        reply_id = :parent_id
    SQL

    children.map { |child_hash| Reply.new(child_hash) }
  end
end
