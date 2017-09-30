class TrendData
  attr_accessor :date, :total_downloads, :total_rank, :daily_downloads, :daily_rank

  def self.msgpack_type
    0x01
  end

  def to_msgpack_ext
    MessagePack.pack [@date.jd, @total_downloads, @total_rank, @daily_downloads, @daily_rank]
  end

  def self.from_msgpack_ext(data)
    jd, total_downloads, total_rank, daily_downloads, daily_rank = MessagePack.unpack(data)
    self.new(Date.jd(jd), total_downloads, total_rank, daily_downloads, daily_rank)
  end

  def initialize(date, total_downloads, total_rank, daily_downloads, daily_rank)
    @date, @total_downloads, @total_rank, @daily_downloads, @daily_rank = date, total_downloads, total_rank, daily_downloads, daily_rank
  end

  def ==(other)
    @date == other.date \
      && @total_downloads == other.total_downloads \
      && @total_rank == other.total_rank \
      && @daily_downloads == other.daily_downloads \
      && @daily_rank == other.daily_rank
  end

  MessagePack::DefaultFactory.register_type(self.msgpack_type, self, packer: :to_msgpack_ext, unpacker: :from_msgpack_ext)
end
