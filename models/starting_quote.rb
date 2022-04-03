class StartingQuote
  def initialize(*args, &block)
    @ar_rec = StartingQuoteAR.new(*args, &block)
  end

  def self.random_line(line_no)
    StartingQuoteAR.where(line: line_no).sample[:text]
  end

  def [](key)
    @ar_rec[key]
  end

  def []=(key, value)
    @ar_rec[key] = value
  end

  def save
    @ar_rec.save
  end
end

class StartingQuoteAR < ActiveRecord::Base
  self.table_name = "starting_quotes"
end 