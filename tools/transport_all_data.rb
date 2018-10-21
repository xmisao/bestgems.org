require "open-uri"
require "json"
require "net/http"
require "logger"
require "parallel"
require "retriable"
require "uri"
require_relative "./bestgems_api"

class TransportAllData
  def initialize(reader_api_base:, writer_api_base:, api_key:)
    @reader_api_base, @writer_api_base, @api_key = reader_api_base, writer_api_base, api_key
  end

  def api_key
    @api_key
  end

  def logger
    @logger ||= Logger.new(STDOUT)
  end

  def execute
    transport_statistics
    transport_gems_with_trends
  end

  def reader_api
    @reader_api ||= BestGemsApi.new(@reader_api_base)
  end

  def writer_api
    @writer_api ||= BestGemsApi.new(@writer_api_base, @api_key)
  end

  def transport_statistics
    logger.info("gems_count")
    writer_api.put_gems_count(reader_api.gems_count)

    logger.info("downloads_total")
    writer_api.put_downloads_total(reader_api.downloads_total)

    logger.info("downloads_daily")
    writer_api.put_downloads_daily(reader_api.downloads_daily)
  end

  def transport_gems_with_trends
    logger.info("gems_with_trends")

    page = 1

    loop do
      logger.info(page)

      gems = retry_with { reader_api.gems(page) }

      break unless gems.count > 0

      Parallel.each(gems, in_processes: 4) do |gem|
        retry_with { writer_api.put_gem(gem) }

        trends = retry_with { reader_api.trends(gem["name"]) }

        retry_with { writer_api.put_trends(gem, trends) }
      end

      page += 1
    end
  end

  def retry_with
    Retriable.retriable(tries: 20) do
      begin
        yield
      rescue => e
        @logger.warn(error_class: e.class.name, error_message: e.message)

        raise
      end
    end
  end
end

TransportAllData.new(reader_api_base: ARGV[0], writer_api_base: ARGV[1], api_key: ARGV[2]).execute
