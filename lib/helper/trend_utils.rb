module TrendUtils
  MAX_GEMS_PER_COMPARISON = 10
  CHART_COLORS = [
    "#E63946", "#F78C25", "#F4D35E", "#80C904", "#2EC4B6",
    "#219EBC", "#5C7AFF", "#6C1DC9", "#C084FC", "#FF6F91"
  ].freeze
  POPULAR_GEM_COMPARISONS = [
    {
      title: "Web App Frameworks",
      gems: %w(rails sinatra hanami roda),
    },
    {
      title: "Background Jobs",
      gems: %w(sidekiq resque delayed_job),
    },
    {
      title: "Test Frameworks",
      gems: %w(rspec minitest),
    },
    {
      title: "Object-relational mapping",
      gems: %w(activerecord sequel rom),
    },
    {
      title: "Pagination",
      gems: %w(pagy kaminari will_paginate),
    }
  ].freeze

  def build_trends_redirect_url(params)
    return nil unless params[:gems] && !params[:gems].empty?

    if params[:current_gems]
      all_gems = combine_gem_lists(params[:current_gems], params[:gems])
    else
      all_gems = parse_comma_separated_gems(params[:gems])
    end

    return "/trends/#{all_gems.join('-vs-')}" if all_gems.any?

    nil
  end

  def fetch_valid_gems(gem_names)
    gem_names.map { |name|
      gem = Gems.fetch_gem_by_name(name)
      gem if gem&.enable
    }.compact
  end

  def build_gems_data(gems, date)
    gems.map.with_index do |gem, index|
      latest = gem.latest_trend(date)
      {
        name: gem.name,
        summary: gem.description,
        total_downloads: latest[:total_downloads],
        total_rank: latest[:total_ranking],
        daily_downloads: latest[:daily_downloads],
        daily_rank: latest[:daily_ranking],
        github_url: gem.github_url,
        color: CHART_COLORS[index % CHART_COLORS.length]
      }
    end
  end

  def merge_downloads_trends_data(trends_arrays)
    merge_trends_data(trends_arrays, [:total_downloads, :daily_downloads])
  end

  def merge_ranking_trends_data(trends_arrays)
    merge_trends_data(trends_arrays, [:total_ranking, :daily_ranking])
  end

  def merge_num_of_versions_trends_data(trends_arrays)
    merge_trends_data(trends_arrays, [:num])
  end

  def remove_gem_url(gems_data, gem_to_remove)
    remaining_gems = gems_data.map { |g| g[:name] } - [gem_to_remove[:name]]
    remaining_gems.any? ? "/trends/#{remaining_gems.join('-vs-')}" : "/trends"
  end

  def chart_datasets(gems_data, data_array)
    gems_data.each_with_index.map do |gem, index|
      {
        label: gem[:name],
        borderColor: gem[:color],
        backgroundColor: gem[:color],
        fill: false,
        pointRadius: 0,
        borderWidth: 2,
        data: data_array[index]
      }
    end
  end
  
  def chart_data_json(labels, datasets)
    {
      labels: labels,
      datasets: datasets
    }.to_json
  end

  private

  def parse_comma_separated_gems(gems_string)
    return [] unless gems_string && !gems_string.empty?

    gems_string.split(',').map(&:strip).reject(&:empty?)
  end

  def combine_gem_lists(current_gems_string, new_gems_string)
    current_gems = parse_comma_separated_gems(current_gems_string)
    new_gems = parse_comma_separated_gems(new_gems_string)

    (current_gems + new_gems).uniq
  end

  def merge_trends_data(trends_arrays, data_keys)
    return {} if trends_arrays.empty?

    all_dates = extract_all_dates(trends_arrays)
    gems_data_by_date = build_gems_data_by_date(trends_arrays)

    merged_data = { labels: all_dates }

    data_keys.each do |key|
      merged_data[key] = gems_data_by_date.map do |gem_data|
        all_dates.map { |date| n2n(gem_data.dig(date, key)) }
      end
    end

    merged_data
  end

  def extract_all_dates(trends_arrays)
    trends_arrays
      .flat_map { |trends| trends.map { |t| t[:date] } }
      .uniq
      .sort
  end

  def build_gems_data_by_date(trends_arrays)
    trends_arrays.map do |trends|
      trends.each_with_object({}) { |trend, hash| hash[trend[:date]] = trend }
    end
  end
end