class DiscordBotLogger
  def initialize(config)
    yyyymm = DateTime.now.strftime("%Y-%m")

    @logger = Logger.new(config['LOG_DIR'] + "#{yyyymm}.log")
    
    @logger.formatter = -> (_severity, _datetime, _progname, message) do
      return "-\n" if message.blank?
      
      return "#{current_time()}: #{message}\n"
    end    
  end

  def log(msg, severity = Logger::Severity::INFO)
    @logger.add(severity, msg)
    puts msg
  end

  def current_time
    DateTime.now.strftime("%Y/%m/%d-%H:%M:%S")
  end

  def log_event(event)
    msg = <<~MSG
    
    New command received:
    "#{event.command.name} - message: #{event.message}"
    MSG

    log(msg)
  end

  def log_bot_start()
    msg = <<~MSG

    Starting bot!

    MSG
    
    log(msg)
  end

  def log_error(error)
    backtrace_lines = error.backtrace.map { |msg| "- #{msg}" }.join("\n")

    msg = <<~MSG
    "An error has occurred:"
    "#{error.message}\n#{backtrace_lines}"
    MSG

    log(msg)
  end
end