class QuestionFollow
  attr_accessor :question_id, :user_id

  def initialize(options)
    @question_id = options['question_id']
    @user_id = options['user_id']
    @id = options['id']
  end

  def create
    raise "#{self} already in database" if @id
    QuestionDatabase.instance.execute(<<-SQL, @question_id, @user_id)
      INSERT INTO
        question_follow(question_id, user_id)
      VALUES
        (?,?)
    SQL
    @id = QuestionDatabase.instance.last_insert_row_id
  end


  def self.followers_for_question_id(question_id)
    data = QuestionDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        users.*
      FROM
        users
      JOIN
        question_follow ON users.id = question_follow.user_id
      WHERE
        question_follow.question_id = ?
    SQL
    data.map { |datum| User.new(datum) }
  end

  def self.followed_questions_for_user_id(user_id)
    data = QuestionDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        questions.*
      FROM
        questions
      JOIN
        question_follow ON questions.id = question_follow.question_id
      WHERE
        question_follow.user_id = ?
    SQL
    data.map { |datum| Question.new(datum) }
  end

  def self.most_followed_questions(n)
    data = QuestionDatabase.instance.execute(<<-SQL, n)
      SELECT
        questions.*
      FROM
        questions
      JOIN
        question_follow ON questions.id = question_follow.question_id
      GROUP BY
        questions.id
      ORDER BY
        COUNT(question_follow.user_id) DESC
      LIMIT
        ?
    SQL

    data.map { |datum| Question.new(datum) }
  end

end
