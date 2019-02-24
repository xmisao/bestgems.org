class CategoryChange
  class ValidationError < StandardError; end

  BELIEVE_STRING = 'believe'

  def initialize(gem, categories, token, believe)
    @gem, @categories, @token, @believe = gem, categories, token, believe
  end

  def execute
    raise ValidationError unless valid?

    DB.transaction do
      GemCategory.update_relations(@gem, @categories)
    end
  end

  def valid?
    @believe == BELIEVE_STRING && @token.valid?
  end
end
