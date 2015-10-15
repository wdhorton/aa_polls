class User < ActiveRecord::Base
  validates :user_name, presence: true

  has_many(
    :authored_polls,
    class_name: "Poll",
    foreign_key: :author_id,
    primary_key: :id
  )

  has_many(
    :responses,
    class_name: "Response",
    foreign_key: :user_id,
    primary_key: :id
  )

  def sql_completed_polls
    sql = <<-SQL
      SELECT
        polls.*
      FROM
        polls
      JOIN
        questions
      ON questions.poll_id = polls.id
      JOIN
        answer_choices
      ON answer_choices.question_id = questions.id
      LEFT OUTER JOIN
       (SELECT
          responses.*
        FROM
          responses
        WHERE
          responses.user_id = ?) AS user_responses
      ON user_responses.answer_choice_id = answer_choices.id
      GROUP BY
        polls.id
      HAVING
        COUNT(DISTINCT questions.id) = COUNT(user_responses.id)
    SQL

    Poll.find_by_sql([sql, id])
  end

  def completed_polls
    join_sql = <<-SQL
    LEFT OUTER JOIN
      responses ON responses.answer_choice_id = answer_choices.id
    SQL

    Poll
      .joins(questions: :answer_choices)
      .joins(join_sql)
      .where("responses.user_id = ?", id)
      .group("polls.id")
      .having("COUNT(DISTINCT questions.id) = COUNT(responses.id)")
  end
end
