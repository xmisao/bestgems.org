STDOUT.sync = true

require "open-uri"
require "json"
require "net/http"
require "logger"
require "parallel"
require "retriable"
require "uri"
require "kafka"
require_relative "./bestgems_api"
require_relative "./rubygems_api"

class GemDetailSendingConsumer
  def initialize(bestgems_api_base:, api_key:, kafka_server:, kafka_username:, kafka_password:)
    @bestgems_api_base, @api_key, @kafka_server, @kafka_username, @kafka_password = bestgems_api_base, api_key, kafka_server, kafka_username, kafka_password
  end

  def kafka
    @kafka ||= Kafka.new(
      [@kafka_server],
      client_id: "gem_detail_sending_consumer",
      sasl_plain_username: @kafka_username,
      sasl_plain_password: @kafka_password,
      sasl_over_ssl: false,
    )
  end

  def consumer
    @consumer ||= kafka.consumer(group_id: "gem_detail_sending_consumer_group")
  end

  def api_key
    @api_key
  end

  def logger
    @logger ||= Logger.new(STDOUT)
  end

  def execute
    consumer.subscribe("gem_detail_sending")

    trap("TERM") { consumer.stop }

    consumer.each_message do |message|
      logger.info(offset: message.offset, key: message.key, value: message.value)

      gem_name = JSON.parse(message.value)["gem_name"]

      process_gem(gem_name)
    end
  end

  def process_gem(gem_name)
    logger.info(gem_name: gem_name)

    info = retry_with { rubygems_api.info(gem_name) }

    unless info
      logger.error(type: :fetch_info_failed, gem_name: gem_name)

      return
    end

    retry_with { bestgems_api.put_detail(info) }
    retry_with { bestgems_api.put_dependencies(info) }

    versions = retry_with { rubygems_api.versions(gem_name) }

    unless versions
      logger.error(type: :fetch_versions_failed, gem_name: gem_name)

      return
    end

    retry_with { bestgems_api.put_versions(gem_name, versions) }

    owners = retry_with { rubygems_api.owners(gem_name) }

    unless owners
      logger.error(type: :fetch_owners_failed, gem_name: gem_name)

      return
    end

    retry_with { bestgems_api.put_owners(gem_name, owners) }
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

GemDetailSendingConsumer.new(bestgems_api_base: ARGV[0], api_key: ARGV[1], kafka_server: ARGV[2], kafka_username: ARGV[3], kafka_password: ARGV[4]).execute
