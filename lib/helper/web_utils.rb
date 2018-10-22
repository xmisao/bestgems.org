module WebUtils
  class BadRequest < StandardError; end
  class Forbidden < StandardError; end
  class NotFound < StandardError; end

  def web_handler(require_authentication: false, succeed: 200)
    begin
      authentication! if require_authentication

      [succeed, yield]
    rescue BadRequest => e
      WebLogger.error(error_class: e.class, error_message: e.message, error_backtrace: e.backtrace)

      400
    rescue Forbidden => e
      WebLogger.error(error_class: e.class, error_message: e.message, error_backtrace: e.backtrace)

      403
    rescue NotFound => e
      WebLogger.error(error_class: e.class, error_message: e.message, error_backtrace: e.backtrace)

      404
    rescue => e
      WebLogger.error(error_class: e.class, error_message: e.message, error_backtrace: e.backtrace)

      500
    end
  end

  def api_handler(require_authentication: false, succeed: 200)
    content_type :json

    web_handler(require_authentication: require_authentication, succeed: succeed) do
      yield
    end
  end

  def authentication!
    raise Forbidden if Settings.api_key.nil? || Settings.api_key.empty? || Settings.api_key != params["api_key"]
  end

  def json
    @json ||= begin
                JSON.parse(request.body.read)
              rescue => e
                raise BadRequest
              end
  end

  def page
    @page ||= if params[:page]
                raise BadRequest unless params[:page].match(/\A\d{1,4}\Z/)

                params[:page].to_i
              else
                1
              end
  end

  def expect(resource)
    raise NotFound unless resource

    resource
  end
end
