require "json"
require "time"
require "uri"
require "net/http"
require "logger"
require "aws-sdk"

class ServerError < StandardError; end
class UnexpectedResponseError < StandardError; end

$log = Logger.new(STDOUT)

def execute(event:, context:)
  event["Records"].each do |record|
    process_record(record)
  end

  {statusCode: 200, body: {event: event, context: context}.to_json}
rescue => e
  $log.error(error_class: e.class.name, error_message: e.message, error_backtrace: e.backtrace)

  # TODO Send to Raven
  raise e
end

def process_record(record)
  name = JSON.parse(record["body"])["name"]

  uri = URI.parse("https://rubygems.org/api/v1/versions/#{name}.json")
  response = Net::HTTP.get_response(uri)

  return if response.code =~ /^4/
  raise ServerError if response.code =~ /^5/
  raise UnexpectedResponseError unless response.code =~ /^2/

  data = JSON.parse(response.body)

  firehose = Aws::Firehose::Client.new(region: "ap-northeast-1")
  firehose.put_record(
    delivery_stream_name: ENV["DELIVERY_STREAM_NAME"],
    record: to_firehose_record(name, Time.now, data),
  )
rescue => e
  $log.error(response_code: response.code, response_body: response.body)

  raise
end

def to_firehose_record(gem_name, timestamp, data)
  serialized_data = data.map { |d|
    {
      gem_name: gem_name,
      timestamp_utc: timestamp.getutc.strftime("%F %H:%M:%S.%L"),
      downloads_count: d["downloads_count"],
      number: d["number"],
    }.to_json + "\n"
  }.join

  {data: serialized_data}
end
