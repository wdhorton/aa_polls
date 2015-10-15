class Question < ActiveRecord::Base
  validates :poll_id, presence: true
  validates :text, presence: true

  belongs_to(
    :poll,
    class_name: "Poll",
    foreign_key: :poll_id,
    primary_key: :id
  )

  has_many(
    :answer_choices,
    class_name: "AnswerChoice",
    foreign_key: :question_id,
    primary_key: :id
  )

  has_many(
    :responses,
    through: :answer_choices,
    source: :responses
  )

  def n_1_results
    results = {}
    answer_choices.each do |choice|
      results[choice.text] = choice.responses.count
    end

    results
  end

  def ok_results
    results = {}
    answer_choices.includes(:responses).each do |choice|
      results[choice.text] = choice.responses.length
    end

    results
  end

  def results
    results = {}
    choices_with_counts = answer_choices
          .select("answer_choices.*, COUNT(responses.id) AS num_responses")
          .joins("LEFT OUTER JOIN responses ON responses.answer_choice_id = answer_choices.id")
          .where("answer_choices.question_id = ?", id)
          .group("answer_choices.id")

    choices_with_counts.each do |choice|
      results[choice.text] = choice.num_responses
    end

    results
  end

end
