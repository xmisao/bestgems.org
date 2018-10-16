def batch_trace(class_name, method_name, *args)
  BatchLogger.info(type: :trace_begin, class: class_name, method: method_name, args: args)
  begin
    yield
  rescue => e
    BatchLogger.error(type: :trace_exception, class: class_name, method: method_name, error_class: e.class.name, error_message: e.message, error_backtrace: e.backtrace)
    raise e
  ensure
    BatchLogger.info(type: :trace_end, class: class_name, method: method_name)
  end
end
