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

class GemDetailSendingProducer
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
    produce_gem_detail_sending
  end

  def produce_gem_detail_sending
    logger.info("produce_gem_detail_sending")

    page = 1

    loop do
      logger.info(page)

      gems = retry_with { bestgems_api.gems(page) }

      break unless gems.count > 0

      gems.each do |gem|
        message = {gem_name: gem["name"]}.to_json
        kafka.deliver_message(message, topic: "gem_detail_sending")
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

GemDetailSendingProducer.new(bestgems_api_base: ARGV[0], api_key: ARGV[1], kafka_server: ARGV[2], kafka_username: ARGV[3], kafka_password: ARGV[4]).execute
