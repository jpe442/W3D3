class Reply

  def initialize(options)
    @subject_question_id = options['subject_question_id']
    @parent_reply_id = options['parent_reply_id']
    @user_id = options['user_id']
    @body = options['body']
    @id = options['id']
  end

  def create
    raise "#{self} already in database" if @id
    QuestionDatabase.instance.execute(<<-SQL, @subject_question_id, @parent_reply_id, @user_id, @body)
      INSERT INTO
        replies(subject_question_id, parent_reply_id, user_id, body)
      VALUES
        (?,?,?,?)
    SQL
    @id = QuestionDatabase.instance.last_insert_row_id
  end

  def author
    User.find_by_id(@user_id)
  end

  def question
    Question.find_by_id(@subject_question_id)
  end

  def parent_reply
    Reply.find_by_id(@parent_reply_id)
  end

  def child_replies
    data = QuestionDatabase.instance.execute(<<-SQL, @id)
      SELECT
        *
      FROM
        replies
      WHERE
        parent_reply_id = ?
    SQL

    data.map { |datum| Reply.new(datum) }

  end

  def self.find_by_id(reply_id)
    data = QuestionDatabase.instance.execute(<<-SQL, reply_id)
      SELECT * FROM replies WHERE id = ?
      SQL

    data.map { |datum| Reply.new(datum) }.first
  end

  def self.find_by_user_id(user_id)
    data = QuestionDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        replies
      WHERE
        user_id = ?
    SQL
    data.map { |datum| Reply.new(datum) }
  end

  def self.find_by_question_id(question_id)
    data = QuestionDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        replies
      WHERE
        subject_question_id = ?
    SQL
    data.map { |datum| Reply.new(datum) }
  end

end
