class TrendData
  attr_accessor :date, :total_downloads, :total_ranking, :daily_downloads, :daily_ranking

  def self.msgpack_type
    0x01
  end

  def to_msgpack_ext
    MessagePack.pack [@date.jd, @total_downloads, @total_ranking, @daily_downloads, @daily_ranking]
  end

  def self.from_msgpack_ext(data)
    jd, total_downloads, total_ranking, daily_downloads, daily_ranking = MessagePack.unpack(data)
    self.new(Date.jd(jd), total_downloads, total_ranking, daily_downloads, daily_ranking)
  end

  def initialize(date, total_downloads, total_ranking, daily_downloads, daily_ranking)
    @date, @total_downloads, @total_ranking, @daily_downloads, @daily_ranking = date, total_downloads, total_ranking, daily_downloads, daily_ranking
  end

  def key(gem_id)
    sprintf("%d.%04d%02d", gem_id, @date.year, @date.month)
  end

  def ==(other)
    return false unless other.is_a? TrendData

    @date == other.date \
      && @total_downloads == other.total_downloads \
      && @total_ranking == other.total_ranking \
      && @daily_downloads == other.daily_downloads \
      && @daily_ranking == other.daily_ranking
  end

  MessagePack::DefaultFactory.register_type(self.msgpack_type, self, packer: :to_msgpack_ext, unpacker: :from_msgpack_ext)
end
