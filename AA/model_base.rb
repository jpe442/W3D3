class ModelBase
  def save(table_name)
    options = instance_variables.map { |el| el.to_s }
    options.delete('@id')
    if @id
      puts options.length
      QuestionDatabase.instance.execute(<<-SQL, *options, *options, @id)
        UPDATE
          table_name(?)
        SET
          (?)
        WHERE
          id = ?
      SQL
    else
      QuestionDatabase.instance.execute(<<-SQL, options, options)
        INSERT INTO
          table_name(?)
        VALUES
          ?
      SQL
      @id = QuestionDatabase.instance.last_insert_row_id
    end
  end
end
