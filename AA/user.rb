require_relative 'question_database'
require_relative 'model_base'

class User < ModelBase
  attr_accessor :first_name, :last_name
  attr_reader :id

  def initialize(options)
    @first_name = options['first_name']
    @last_name = options['last_name']
    @id = options['id']
  end

  def create
    QuestionDatabase.instance.execute(<<-SQL, first_name, last_name)
      INSERT INTO
        users(first_name, last_name)
      VALUES
        (?,?)
    SQL
    @id = QuestionDatabase.instance.last_insert_row_id
  end

  def save
    super('users')
  end

  def authored_questions
    Question.find_by_author_id(@id)
  end

  def followed_questions
    QuestionFollow.followed_questions_for_user_id(@id)
  end

  def authored_replies
    Reply.find_by_user_id(@id)
  end

  def liked_questions
    QuestionLike.liked_questions_for_user_id(@id)
  end

  def average_karma
    data = QuestionDatabase.instance.execute(<<-SQL, @id)
      SELECT
        COUNT(likes.id) as number_likes, COUNT(DISTINCT questions.id) as number_questions,
        (COUNT(likes.id) * 1.0) /COUNT(DISTINCT questions.id) as karma
      FROM
        users
      JOIN
        questions ON users.id = questions.associated_author_id
      JOIN
        likes ON likes.question_id = questions.id
      WHERE
        users.id = ?
    SQL
    puts data
    data[0]['karma']
  end

  def self.all
    data = QuestionDatabase.instance.execute(<<-SQL)
      SELECT
        *
      FROM
        users
    SQL
    data.map { |datum| User.new(datum) }
  end

  def self.find_by_id(id)
    data = QuestionDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        users
      WHERE
        id = ?
    SQL
    data.map { |datum| User.new(datum) }.first
  end

  def self.find_by_name(fname, lname)
    data = QuestionDatabase.instance.execute(<<-SQL, fname, lname)
      SELECT
        *
      FROM
        users
      WHERE
        first_name = ?
      AND
        last_name = ?
    SQL
    data.map { |datum| User.new(datum) }
  end
end
