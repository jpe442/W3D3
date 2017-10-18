require_relative 'user'
require_relative 'question'
require_relative 'reply'
require_relative 'question_follow'
require_relative 'question_like'

users = []
100.times do |i|
  user = User.new('first_name'=> "bob#{i}", 'last_name'=> "Bobertton#{i}")
  user.create
  users << user
end

u = users.sample
puts u.id

questions = []
50.times do |i|
  question = Question.new('title'=> "question#{i}", 'body'=>'Lorem Ipsum', 'associated_author_id'=> users.sample.id)
  questions << question
  question.create
end


40.times do |i|
  parent = 0
  parent = (1...i).to_a.sample if i % 5 == 0
  if parent == 0
    reply = Reply.new('subject_question_id'=> questions.sample.id, 'user_id'=> users.sample.id, 'body'=> "Lorem Ipsum#{i}")
  else
    reply = Reply.new('subject_question_id'=> questions.sample.id,
      'user_id'=> users.sample.id, 'body'=> "Lorem Ipsum#{i}", 'parent_reply_id'=> parent)
  end

  reply.create
end

30.times do |i|
  user = users.sample
  question = questions.sample
  follow = QuestionFollow.new('user_id' => user.id, 'question_id'=> question.id)
  follow.create
end

200.times do |i|
  user = users.sample
  question = questions.sample
  like = QuestionLike.new('user_id' => user.id, 'question_id'=> question.id)
  like.create
end
