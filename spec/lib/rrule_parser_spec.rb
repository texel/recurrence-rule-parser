require 'lib/rrule_parser'
require 'icalendar'

module RruleParserSpecHelper
  def create_default_event
    @interval    = 2
    @frequency   = "WEEKLY"
    @byday       = "MO,WE,FR"
    @event       = Icalendar::Event.new
    @event.start = Time.now
    @event.end   = Time.now + 3600
    @event.recurrence_rules = ["FREQ=#{@frequency};INTERVAL=#{@interval};BYDAY=#{@byday};WKST=SU"]
  end
  
  def create_parser(event)
    @parser = RruleParser.new(event)
  end
  
  def create_default_parser
    create_default_event
    create_parser(@event)
  end
end

describe RruleParser do
  include RruleParserSpecHelper
  
  describe "#new" do
    context "when passed a valid event object" do
      before(:each) do
        create_default_event
      end
      
      it "should create a new RruleParser object" do
        rrp = RruleParser.new(@event)
        rrp.should be_an_instance_of(RruleParser)
      end
    end
  end
  
  describe "#rules" do
    context "with a valid event object" do
      before(:each) do
        create_default_parser
      end
      
      it "should be a hash" do
        @parser.rules.should be_an_instance_of(Hash)
      end
      
      it "should have keys corresponding to rules" do
        %w(FREQ INTERVAL BYDAY WKST).map {|m| m.downcase}.map {|m| m.to_sym}.each do |key|
          @parser.rules.keys.should include(key)
        end
      end
      
      it "should split rules containing commas into arrays" do
        @parser.rules[:byday].should be_an_instance_of(Array)
      end
    end
  end
  
  describe "#expressions" do
    before(:each) do
      create_default_parser
    end
    
    it "should return an array" do
      @parser.expressions.should be_an_instance_of(Array)
    end
  end
  
  describe "#parse_frequency_and_interval" do
    before(:each) do
      create_default_parser
      @result = @parser.send(:parse_frequency_and_interval)
    end
    
    it "return a valid temporal expression" do
      @result.should be_an_instance_of(Runt::EveryTE)
    end
    
    it "should have the correct interval" do
      @result.instance_variable_get("@interval").should == @interval
    end
    
    it "should have the correct frequency" do
      @result.instance_variable_get("@precision").should == Runt::DPrecision.const_get(RruleParser::ADVERB_MAP[@frequency])
    end
  end
end