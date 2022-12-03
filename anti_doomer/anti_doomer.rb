# Look away

class AntiDoomer
  def initialize(sentiment_analyser, logger)
    @sentiment_analyser = sentiment_analyser
    @logger = logger
  end

  def log(msg)
    @logger.log(msg)
  end

  def is_dooming_about_anji?(text)
    return false unless message_is_about_anji?(text)

    negators = count_negators(text)
    return false if negators > 2

    log("text is '#{text}' length #{text.length} negators = #{negators}")

    return true if definitely_dooming_about_anji(text)

    score = @sentiment_analyser.analyze(text)

    if text.length < 50 && negators % 2 == 1
      log("reversing score!")
      score = -score
    end

    log("score = #{score}")

    return score < 0
  end

  def anji_regex
    /anji'*s*([ -]?mito)?/i
  end

  def anji_topics
    [
      anji_regex,
      /kou /i,
      /shitsu/i,
      /parry super/i,
      /parry overdrive/i,
      /fuu?jin/i,
      /fan toss/i,
      /fan super/i,
      /fan overdrive/i,
      /ichishiki/i,
      /nagiha/i,
      /rin /i,
      /kachou?fuu?getsu/i
    ]
  end

  def doomer_regexes
    [
      /delete #{anji_regex.source}/i,
      /deleting #{anji_regex.source}/i,
    ]
  end

  def definitely_dooming_about_anji(text)
    doomer_regexes.any? { |doomer_regex| doomer_regex.match(text) }
  end

  def message_is_about_anji?(text)
    anji_topics.any? { |topic_regex| topic_regex.match(text) }
  end

  def count_negators(text)
    text.split.count { |word| word.match(/hasn'?t|not|isn'?t|doesn'?t|don'?t/i) }
  end

end