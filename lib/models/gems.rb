class Gems < Sequel::Model
  def self.search(date, query)
    like_clause = query.split(/\s+/)[0..4].inject(nil) { |like_clause, q|
      cond = (Sequel.ilike(:name, "%#{q}%") | Sequel.ilike(:summary, "%#{q}%"))
      like_clause ? like_clause & cond : cond
    }

    Gems.where(latest_update_date: date, enable: true).where(like_clause).order(:latest_total_ranking)
  end

  def self.fetch_gems_on_page(page, per_page = 1000)
    offset = (page - 1) * per_page

    self.order(:id).offset(offset).limit(per_page).to_a
  end

  def self.fetch_gem_by_name(name)
    Gems.where(:name => name).first
  end

  def self.fetch_by_ids(gem_ids)
    return [] if gem_ids.empty?

    Gems.where(id: gem_ids, enable: true).to_a
  end

  def self.fetch_by_ids_ordered_by_total_downloads(gem_ids)
    return [] if gem_ids.empty?

    Gems.where(id: gem_ids, enable: true).order(:latest_total_downloads).to_a.reverse
  end

  def self.from_json(json)
    self.new(
      name: json["name"],
      summary: json["summary"],
      version: json["version"],
      latest_total_downloads: json["latest_total_downloads"],
      latest_total_ranking: json["latest_total_ranking"],
      latest_daily_downloads: json["latest_daily_downloads"],
      latest_daily_ranking: json["latest_daily_ranking"],
      latest_update_date: json["latest_update_date"],
    )
  end

  def update_by_json(json)
    self.name = json["name"]
    self.summary = json["summary"]
    self.version = json["version"]
    self.latest_total_downloads = json["latest_total_downloads"]
    self.latest_total_ranking = json["latest_total_ranking"]
    self.latest_daily_downloads = json["latest_daily_downloads"]
    self.latest_daily_ranking = json["latest_daily_ranking"]
    self.latest_update_date = json["latest_update_date"]
  end

  def total_downloads_trends()
    Value.where(:gem_id => self[:id], :type => Value::Type::TOTAL_DOWNLOADS)
         .order(:date)
         .select(:date, Sequel.as(:value, :downloads))
  end

  def daily_downloads_trends()
    Value.where(:gem_id => self[:id], :type => Value::Type::DAILY_DOWNLOADS)
         .order(:date)
         .select(:date, Sequel.as(:value, :downloads))
  end

  def downloads_trends()
    DB.from(total_downloads_trends.as(:T))
      .left_outer_join(daily_downloads_trends.as(:D), :T__date => :D__date)
      .order(:T__date)
      .select(:T__date, Sequel.as(:T__downloads, :total_downloads), Sequel.as(:D__downloads, :daily_downloads))
  end

  def total_ranking_trends()
    Ranking.where(:gem_id => self[:id], :type => Ranking::Type::TOTAL_RANKING)
           .order(:date)
           .select(:date, :ranking)
  end

  def daily_ranking_trends()
    Ranking.where(:gem_id => self[:id], :type => Ranking::Type::DAILY_RANKING)
           .order(:date)
           .select(:date, :ranking)
  end

  def ranking_trends()
    DB.from(total_ranking_trends.as(:T))
      .left_outer_join(daily_ranking_trends.as(:D), :T__date => :D__date)
      .order(:T__date)
      .select(:T__date, Sequel.as(:T__ranking, :total_ranking), Sequel.as(:D__ranking, :daily_ranking))
  end

  def latest_trend(date)
    if date == self[:latest_update_date]
      {
        total_downloads: self[:latest_total_downloads],
        daily_downloads: self[:latest_daily_downloads],
        total_ranking: self[:latest_total_ranking],
        daily_ranking: self[:latest_daily_ranking],
      }
    elsif self[:latest_update_date] && date < self[:latest_update_date]
      # This state will occure when running update_gems_latest_columns.rb
      # Should failback to old means

      info(date) || {
        total_downloads: nil,
        daily_downloads: nil,
        total_ranking: nil,
        daily_ranking: nil,
      }
    else
      {
        total_downloads: nil,
        daily_downloads: nil,
        total_ranking: nil,
        daily_ranking: nil,
      }
    end
  end

  def info(date)
    Gems.where(:name => self[:name])
        .join(Value.where(:type => Value::Type::TOTAL_DOWNLOADS,
                          :date => date).as(:TD),
              :gems__id => :TD__gem_id)
        .left_join(Value.where(:type => Value::Type::DAILY_DOWNLOADS,
                               :date => date).as(:DD),
                   :gems__id => :DD__gem_id)
        .join(Ranking.where(:type => Ranking::Type::TOTAL_RANKING,
                            :date => date).as(:TR),
              :gems__id => :TR__gem_id)
        .left_join(Ranking.where(:type => Ranking::Type::DAILY_RANKING,
                                 :date => date).as(:DR),
                   :gems__id => :DR__gem_id)
        .select(:gems__name,
                :gems__summary,
                :gems__version,
                Sequel.as(:TD__value, :total_downloads),
                Sequel.as(:DD__value, :daily_downloads),
                Sequel.as(:TR__ranking, :total_ranking),
                Sequel.as(:DR__ranking, :daily_ranking))
        .first
  end

  def get_trend_data_from_rdb(date)
    total_downloads = Value.where(gem_id: id, type: Value::Type::TOTAL_DOWNLOADS, date: date).get(:value)
    daily_downloads = Value.where(gem_id: id, type: Value::Type::DAILY_DOWNLOADS, date: date).get(:value)
    total_ranking = Ranking.where(gem_id: id, type: Ranking::Type::TOTAL_RANKING, date: date).get(:ranking)
    daily_ranking = Ranking.where(gem_id: id, type: Ranking::Type::DAILY_RANKING, date: date).get(:ranking)

    TrendData.new(date, total_downloads, total_ranking, daily_downloads, daily_ranking) if total_downloads || total_ranking || daily_downloads || daily_ranking
  end

  def put_trend_data(*td_list)
    Trend.put(id, *td_list)
  end

  def get_trend_data()
    Trend.get(id)
  end

  def to_hash
    {
      gem_id: id,
      name: name,
      summary: summary,
      version: version,
      latest_total_downloads: latest_total_downloads,
      latest_total_ranking: latest_total_ranking,
      latest_daily_downloads: latest_daily_downloads,
      latest_daily_ranking: latest_daily_ranking,
      latest_update_date: latest_update_date,
    }
  end

  def detail
    return @detail if defined? @detail

    @detail = Detail.fetch_by_gem_id(id)
  end

  def description
    if detail && latest_update_date && (latest_update_date - 7).to_time < detail.updated_at
      detail.info
    else
      summary
    end
  end

  def depends_on_gems
    @depended_by_gems ||= DependsOnGem.fetch_by_gem_id(id)
  end

  def depended_by_gems
    @depends_on_gems ||= DependedByGem.fetch_by_gem_id(id)
  end

  def versions
    @versions ||= GemVersion.where(gem_id: id).order(:built_at).to_a
  end

  def num_of_versions_trends(from_date, to_date)
    # NOTE: This method is order sensitive

    return [] unless from_date && to_date

    version_count = Hash.new { |h, k| h[k] = 0 }

    versions.group_by { |v| v.built_at.to_date }.each { |k, v|
      version_count[k] = v.count
    }

    num_of_versions = version_count.select { |(k, v)| k < from_date }.inject(0) { |m, (k, v)| m + v }

    (from_date..to_date).map { |d, m|
      num_of_versions = num_of_versions + version_count[d]

      {date: d, num: num_of_versions}
    }
  end

  def popular_versions_by_major_version
    version_count = Hash.new { |h, k| h[k] = 0 }

    versions.group_by { |v| v.major_version }.each { |k, v|
      version_count[k] += v.inject(0) { |m, va| m + va.downloads_count }
    }

    histgram = version_count.map { |(k, v)| {version: k, downloads: v} }.sort_by { |e| -1 * e[:downloads] }

    if histgram.count > 9
      histgram[0..8] + [histgram[9..-1].each_with_object({version: "Others", downloads: 0}) { |e, m| m[:downloads] += e[:downloads] }]
    else
      histgram
    end
  end

  def popular_versions_by_major_minor_version
    version_count = Hash.new { |h, k| h[k] = 0 }

    versions.group_by { |v| v.major_minor_version }.each { |k, v|
      version_count[k] += v.inject(0) { |m, va| m + va.downloads_count }
    }

    histgram = version_count.map { |(k, v)| {version: k, downloads: v} }.sort_by { |e| -1 * e[:downloads] }

    if histgram.count > 9
      histgram[0..8] << histgram[9..-1].each_with_object({version: "Others", downloads: 0}) { |e, m| m[:downloads] += e[:downloads] }
    else
      histgram
    end
  end

  def categories
    GemCategory.gem_categories(self)
  end

  def owners
    GemOwner.gem_owners(self)
  end

  def link
    "/gems/#{name}"
  end

  def github_url
    detail&.github_url
  end
end
