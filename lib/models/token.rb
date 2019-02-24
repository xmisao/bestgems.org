class Token
  attr_reader :string

  def initialize(string)
    @string = string
  end

  def self.create
    token = SecureRandom.hex

    @@tokens.add(token)

    Token.new(token)
  end

  def valid?
    @valid ||= @@tokens.del(@string)
  end

  class Cache
    def initialize(size = 1024)
      @size = size
      @array = []
    end

    def add(obj)
      @array.shift if @size < @array.size

      @array << obj
    end

    def del(obj)
      !!@array.delete(obj)
    end
  end

  @@tokens = Cache.new
end
