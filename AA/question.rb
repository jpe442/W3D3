require_relative 'question_database'

class Question
  attr_accessor :title, :body, :associated_author_id
  attr_reader :id

  def initialize(options)
    @title = options['title']
    @body = options['body']
    @associated_author_id = options['associated_author_id']
    @id = options['id']
  end

  def create
    raise 'User already in database' if @id
    QuestionDatabase.instance.execute(<<-SQL, @title, @body, @associated_author_id)
      INSERT INTO
        questions(title, body, associated_author_id)
      VALUES
        (?,?,?)
    SQL
    @id = QuestionDatabase.instance.last_insert_row_id
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
    QuestionLike.num_likes_for_question_id(@id)
  end

  def self.most_liked(n)
    QuestionLike.most_liked_questions(n)
  end

  def self.find_by_author_id(id)
    data = QuestionDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        questions
      WHERE
        associated_author_id = ?
    SQL
    data.map { |datum| Question.new(datum) }
  end

  def self.find_by_id(id)
    data = QuestionDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        questions
      WHERE
        id = ?
    SQL
    data.map { |datum| Question.new(datum) }.first
  end

  def self.most_followed(n)
    QuestionFollow.most_followed_questions(n)
  end
end
