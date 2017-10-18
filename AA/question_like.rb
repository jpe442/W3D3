class QuestionLike

  def initialize(options)
    @question_id = options['question_id']
    @user_id = options['user_id']
    @id = options['id']
  end

  def create
    raise "#{self} already in database" if @id
    QuestionDatabase.instance.execute(<<-SQL, @user_id, @question_id)
      INSERT INTO
        likes(user_id, question_id)
      VALUES
        (?,?)
    SQL
    @id = QuestionDatabase.instance.last_insert_row_id
  end

  def self.likers_for_question_id(question_id)
    data = QuestionDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        users.*
      FROM
        users
      JOIN
        likes ON users.id = likes.user_id
      WHERE
        likes.question_id = ?
    SQL
    data.map { |datum| User.new(datum) }
  end

  def self.num_likes_for_question_id(question_id)
    num = QuestionDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        COUNT(id)
      FROM
        likes
      WHERE
        question_id = ?
    SQL
    num.first.values.first
  end

  def self.liked_questions_for_user_id(user_id)
    data = QuestionDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        questions.*
      FROM
        questions
      JOIN
        likes ON questions.id = likes.question_id
      WHERE
        likes.user_id = ?
    SQL
    data.map { |datum| Question.new(datum) }
  end


  def self.most_liked_questions(n)
    data = QuestionDatabase.instance.execute(<<-SQL, n)
      SELECT
        questions.*
      FROM
        questions
      JOIN
        likes ON questions.id = likes.question_id
      GROUP BY
        questions.id
      ORDER BY
        COUNT(likes.user_id) DESC
      LIMIT
        ?
    SQL

    data.map { |datum| Question.new(datum) }
  end

end
