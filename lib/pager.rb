class Pager
  def initialize(path, opts, range, page)
    @path, @opts, @range, @page = path, opts, range, page
  end

  def conv0(hash, page)
    a = []
    hash.each{|k, v|
      if k == 'page'
        a << "#{k}=#{page}"
      else
        a << "#{k}=#{v}"
      end
    }

    a << "page=#{page}" unless hash.has_key?('page')

    a.join('&')
  end

  def previous(p)
    text = '&lt;&lt; Previous'
    if @range.begin <= p
      conv_text(p, text)
    else
      conv_disabled(text)
    end
  end

  def next(p)
    text = '&gt;&gt; Next'
    if p <= @range.end
      conv_text(p, text)
    else
      conv_disabled(text)
    end
  end

  def conv_text(p, text)
    "<li><a href=\"#{@path + '?' + conv0(@opts, p)}\">#{text}</a></li>"
  end

  def conv(p)
    "<li><a href=\"#{@path + '?' + conv0(@opts, p)}\">#{p}</a></li>"
  end

  def conv_active(str)
    "<li class=\"active\"><span>#{str}</span></li>"
  end

  def conv_disabled(str)
    "<li class=\"disabled\"><span>#{str}</span></li>"
  end

  def each(&blk)
    @range.each{|p|
      if p == @page
        yield conv_active(p)
      elsif p == @range.begin
        yield conv(p)
      elsif p == @range.begin + 1
        yield conv(p)
      elsif p == @range.end - 1
        yield conv(p)
      elsif p == @range.end
        yield conv(p)
      elsif @page - 5 < p and p < @page + 5
        yield conv(p)
      elsif p == @page - 5 or @page + 5 == p
        yield conv_active('...')
      end
    }
  end
end
