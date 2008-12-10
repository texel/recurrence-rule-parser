require 'runt'
require 'icalendar'

class RruleParser
  VERSION = '1.0.0'
  
  DAYS = {
    "SU" => Runt::Sunday,
    "MO" => Runt::Monday,
    "TU" => Runt::Tuesday,
    "WE" => Runt::Wednesday,
    "TH" => Runt::Thursday,
    "FR" => Runt::Friday,
    "SA" => Runt::Saturday,
    "SU" => Runt::Sunday
  }
  
  ADVERB_MAP = {
    "DAILY"   => "DAY",
    "WEEKLY"  => "WEEK",
    "MONTHLY" => "MONTH",
    "YEARLY"  => "YEAR"
  }
  
  attr_accessor :event
  attr_accessor :rules
  
  def initialize(event)
    @expressions      = []
    self.rules        = {}
    self.event        = event
    self.parse_rules(event)
  end
  
  # Parse rules, output temporal expressions
  def expressions
    @expressions = []
    @expressions << parse_frequency_and_interval
    @expressions << parse_byday
    @expressions.compact!
    @expressions
  end
  
  def expression
    self.expressions.inject {|m, v| v & m}
  end
  
  protected
  
  def parse_rules(event)
    rrules = event.recurrence_rules

    rrules.each do |rule|
      pairs = rule.split(";")
      pairs.each do |pair|
        array = pair.split('=')
        self.rules[array[0].downcase.to_sym] = array[1]
      end
    end
    
    # Parse comma separated lists.
    self.rules.each do |key, rule|
      if rule =~ /,/
        rules[key] = rule.split(',')
      end
    end
  end
  
  def parse_frequency_and_interval
    if self.rules[:freq]
      frequency = self.rules[:freq]
      interval  = self.rules[:interval] ? self.rules[:interval].to_i : 1
      Runt::EveryTE.new(self.event.start, interval, Runt::DPrecision.const_get(ADVERB_MAP[frequency]))
    end
  end
  
  def parse_byday
    if self.rules[:byday]
      self.rules[:byday].map{ |day| Runt::DIWeek.new(RruleParser::DAYS[day]) }.inject do |m, expr|
        m | expr
      end
    end
  end
end