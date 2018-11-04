STDOUT.sync = true

require "open-uri"
require "json"
require "net/http"
require "logger"
require "parallel"
require "retriable"
require "uri"
require_relative "./bestgems_api"
require_relative "./rubygems_api"

class PutGemDetail
  def initialize(bestgems_api_base:, api_key:)
    @bestgems_api_base, @api_key = bestgems_api_base, api_key
  end

  def api_key
    @api_key
  end

  def logger
    @logger ||= Logger.new(STDOUT)
  end

  def execute
    import_gem_detail
  end

  def process_gem(gem_name)
    logger.info(gem_name: gem_name)

    info = retry_with { rubygems_api.info(gem_name) }

    unless info
      logger.error(type: :fetch_failed, gem_name: gem_name)

      return
    end

    retry_with { bestgems_api.put_detail(info) }
    retry_with { bestgems_api.put_dependencies(info) }
  end

  def import_gem_detail
    logger.info("import_gem_detail")

    page = 1

    loop do
      logger.info(page)

      gems = retry_with { bestgems_api.gems(page) }

      break unless gems.count > 0

      Parallel.each(gems, in_processes: 4) do |gem|
        process_gem(gem["name"])
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

  def bestgems_api
    @bestgems_api ||= BestGemsApi.new(@bestgems_api_base, @api_key)
  end

  def rubygems_api
    @rubygems_api ||= RubyGemsApi.new
  end
end

PutGemDetail.new(bestgems_api_base: ARGV[0], api_key: ARGV[1]).execute
