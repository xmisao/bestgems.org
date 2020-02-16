require "aws-sdk-sqs"
require "logger"
require "open-uri"
require "thread"

THREAD_COUNT = ENV["THREAD_COUNT"].to_i
MAX_RETRY_COUNT = 3
$log = Logger.new(STDOUT)

def execute(event:, context:)
  page = 1

  loop do
    $log.info(page: page)

    gems = retry_with { fetch_gems(page) }

    break unless gems.count > 0

    request_queue = Thread::Queue.new

    gems.each_slice(10) do |gems|
      request_queue << gems
    end

    request_parallel(request_queue, THREAD_COUNT)

    page += 1
  end
end

def request_parallel(queue, thread_count)
  threads = thread_count.times.map do |thread_number|
    Thread.start(queue, thread_number) do |queue, thread_number|
      begin
        loop do
          gems = queue.pop(true)

          request(gems)
        end
      rescue ThreadError
        # Nothing to do
      end
    end
  end

  threads.each(&:join)
end

def request(gems)
  request = {
    entries: gems.map { |gem|
      {
        id: gem["gem_id"].to_s,
        message_body: {"name" => gem["name"]}.to_json,
      }
    },
  }

  result = sqs.send_messages(request)

  if result.failed.count > 0
    $log.warn(failed: result.failed.count)
  end
rescue
  $log.debug(gems: gems, request: request)

  raise
end

def retry_with
  i = 0

  begin
    yield
  rescue
    $log.warn(retry_count: i)

    i += 1

    return if MAX_RETRY_COUNT < i

    retry
  end
end

def sqs
  Aws::SQS::Queue.new(queue_url)
end

def queue_url
  ENV["QUEUE_URL"]
end

def fetch_gems(page)
  open(gems_api_endpoint(page)) { |f|
    JSON.parse(f.read)
  }
end

def gems_api_endpoint(page)
  "#{bestgems_api_base_url}/v2/gems.json?page=#{page}"
end

def bestgems_api_base_url
  ENV["BESTGEMS_API_BASE"]
end
