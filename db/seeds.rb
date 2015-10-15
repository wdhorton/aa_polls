# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

5.times do |i|
  user = User.create!(user_name: "user#{i}")

  2.times do |j|
    poll = user.authored_polls.create!(title: "#{user.user_name}'s poll number #{j}'")

    2.times do |k|
      question = poll.questions.create!(text: "Question #{k}")

      2.times do |l|
        question.answer_choices.create!(text: "Answer #{l}")
      end
    end
  end
end

until Response.all.count == 60
  Response.create(user_id: User.all.sample.id, answer_choice_id: AnswerChoice.all.sample.id )
end

Poll.last.questions.each do |question|
  Response.create(user_id: User.first.id, answer_choice_id: question.answer_choices.first.id)
end
