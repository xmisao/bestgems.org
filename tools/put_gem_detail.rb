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
  def initialize(bestgems_api_base:, api_key:, gem_name:)
    @bestgems_api_base, @api_key, @gem_name = bestgems_api_base, api_key, gem_name
  end

  def api_key
    @api_key
  end

  def logger
    @logger ||= Logger.new(STDOUT)
  end

  def execute
    info = rubygems_api.info(@gem_name)
    bestgems_api.put_detail(info)
    bestgems_api.put_dependencies(info)

    versions = rubygems_api.versions(@gem_name)
    bestgems_api.put_versions(@gem_name, versions)
  end

  def bestgems_api
    @bestgems_api ||= BestGemsApi.new(@bestgems_api_base, @api_key)
  end

  def rubygems_api
    @rubygems_api ||= RubyGemsApi.new
  end
end

PutGemDetail.new(bestgems_api_base: ARGV[0], api_key: ARGV[1], gem_name: ARGV[2]).execute
