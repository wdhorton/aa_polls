class Response < ActiveRecord::Base
  validates :user_id, presence: true
  validates :answer_choice_id, presence: true
  validate :respondent_has_not_already_answered_question
  validate :respondent_is_not_author

  belongs_to(
    :answer_choice,
    class_name: "AnswerChoice",
    foreign_key: :answer_choice_id,
    primary_key: :id
  )

  belongs_to(
    :respondent,
    class_name: "User",
    foreign_key: :user_id,
    primary_key: :id
  )

  has_one(
    :question,
    through: :answer_choice,
    source: :question
  )

  has_one(
    :poll,
    through: :question,
    source: :poll
  )

  def sql_sibling_responses
    sql = <<-SQL
      SELECT
        responses.*
      FROM
        answer_choices AS a1
      JOIN
        answer_choices AS a2
      ON
        a2.question_id = a1.question_id
      JOIN
        responses
      ON
        responses.answer_choice_id = a2.id
      WHERE
        a1.id = ? AND (responses.id != ? OR ? IS NULL)
    SQL

    Response.find_by_sql([sql, answer_choice_id, id, id])
  end

  def sibling_responses
    Response
      .joins(:answer_choice)
      .joins("JOIN answer_choices AS a2 ON a2.question_id = answer_choices.question_id")
      .where("a2.id = ? AND (responses.id != ? OR ? IS NULL)", answer_choice_id, id, id )
  end

  def respondent_has_not_already_answered_question
    if sibling_responses.exists?(user_id: user_id)
      errors.add(:respondent, "can't answer question twice")
    end
  end

  def respondent_is_not_author
    if Poll.joins(questions: :answer_choices).where("answer_choices.id = ?", answer_choice_id).first.author_id == user_id
      errors.add(:respondent, "can't be the author")
    end
  end
end
