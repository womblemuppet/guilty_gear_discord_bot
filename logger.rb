class DiscordBotLogger
  def initialize
    yyyymm = DateTime.now.strftime("%Y-%m")

    @logger = Logger.new("/home/ubuntu/discord_bot/log-#{yyyymm}.log")
    
    @logger.formatter = -> (_severity, _datetime, _progname, message) do
      return "-\n" if message.blank?
      
      return "#{current_time()}: #{message}\n"
    end    

  end

  def current_time
    DateTime.now.strftime("%Y/%m/%d-%H:%M:%S")
  end

  def log_event(event)
    @logger.info("")
    @logger.info("New command received:")
    @logger.info("#{event.command.name} - message: #{event.message}")
  end

  def log(msg)
    @logger.info(msg)
  end

  def log_bot_start()
    @logger.info("")
    @logger.info("Starting bot!")
    @logger.info("")
  end

  def log_error(error)
    @logger.error("An error has occurred:")
    backtrace_lines = error.backtrace.map { |msg| "- #{msg}" }.join("\n")
    @logger.error("#{error.message}\n#{backtrace_lines}")

    @logger.info("")
  end
end