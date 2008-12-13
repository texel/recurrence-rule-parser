require 'lib/rrule_parser'
require 'icalendar'
require 'spec'
require 'redgreen'

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
  
  def create_event
    @event = Icalendar::Event.new
  end
  
  # TODO Make other test objects for shared specs :)
  
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
    
    it "returns a valid temporal expression" do
      @result.should be_an_instance_of(Runt::EveryTE)
    end
    
    it "should have the correct interval" do
      @result.instance_variable_get("@interval").should == @interval
    end
    
    it "should have the correct frequency" do
      @result.instance_variable_get("@precision").should == Runt::DPrecision.const_get(RruleParser::ADVERB_MAP[@frequency])
    end
  end
  
  describe "#dates" do
    context "with an event starting on Monday, 12/1/2008" do
      before(:each) do
        create_event
        @event.start = Time.parse('12/1/2008 3pm')
        @event.end   = Time.parse('12/1/2008 5pm')
      end
      
      context "with a one-month range" do
        before(:each) do
          @range = (Date.civil(2008, 12, 1)..(Date.civil(2009, 1, 1)))
        end
        
        context "recurring every week" do
          before(:each) do
            @event.recurrence_rules = ['FREQ=WEEKLY;INTERVAL=1']
            @range = (Date.civil(2008, 12, 1)..(Date.civil(2009, 1, 1)))
            create_parser(@event)
          end

          it "should return 5 dates" do
            @parser.dates(@range).size.should == 5
          end

          it "should return only Monday dates" do
            @parser.dates(@range).map {|d| d.wday == Runt::Monday }.all?.should be_true
          end
        end

        context "recurring every other week" do
          before(:each) do
            @event.recurrence_rules = ['FREQ=WEEKLY;INTERVAL=2']
            @range = (Date.civil(2008, 12, 1)..(Date.civil(2008, 12, 31)))
            create_parser(@event)
          end

          it "should return 3 dates" do
            @parser.dates(@range).size.should == 3
          end
        end

        context "recurring every Monday, Wednesday, and Friday" do
          before(:each) do
            @event.recurrence_rules = ['FREQ=WEEKLY;INTERVAL=1;BYDAY=MO,WE,FR']
            create_parser(@event)
          end

          it "should return 14 dates" do
            @parser.dates(@range).size.should == 14
          end

          it "should return only dates on Monday, Wednesday, and Friday" do
            @parser.dates(@range).map {|d| [Runt::Mon, Runt::Wed, Runt::Fri].include?(d.wday) }.all?.should be_true
          end
        end
        
        context "recurring every day" do
          before(:each) do
            @event.recurrence_rules = ['FREQ=DAILY;INTERVAL=1']
            create_parser(@event)
          end

          it "should return 31 dates" do
            @parser.dates(@range).size.should == 32
          end
        end
        
        context "recurring every 2 days" do
          before(:each) do
            @event.recurrence_rules = ['FREQ=DAILY;INTERVAL=2']
            create_parser(@event)
          end

          it "should return 31 dates" do
            @parser.dates(@range).size.should == 16
          end
        end
      end
      
      context "with a one-year range" do
        before(:each) do
          @range = (Date.civil(2008, 12, 1)..(Date.civil(2009, 11, 30)))
        end
        
        context "recurring every month" do
          before(:each) do
            @event.recurrence_rules = ['FREQ=MONTHLY;INTERVAL=1']
            create_parser(@event)
          end
          
          it "should return 12 dates" do
            @parser.dates(@range).size.should == 12
          end
          
          it "should return only dates on the same day of the month" do
            @parser.dates(@range).map {|d| d.day == @event.start.day}.all?.should be_true
          end
        end
        
        context "recurring every two months" do
          before(:each) do
            @event.recurrence_rules = ['FREQ=MONTHLY;INTERVAL=2']
            create_parser(@event)
          end
          
          it "should return 6 dates" do
            @parser.dates(@range).size.should == 6
          end
          
          it "should return only dates on the same day of the month" do
            @parser.dates(@range).map {|d| d.day == @event.start.day}.all?.should be_true
          end
        end
        
        context "recurring the first and fifteenth of every month" do
          before(:each) do
            @event.recurrence_rules = ['FREQ=MONTHLY;INTERVAL=1;BYMONTHDAY=1,15']
            create_parser(@event)
          end
          
          it "should return 24 dates" do
            @parser.dates(@range).size.should == 24
          end
          
          it "should return dates only on the 1st and 15th of the month" do
            @parser.dates(@range).map {|d| [1, 15].include?(d.day) }.all?.should be_true
          end
        end
        
        context "recurring the first Monday of every month" do
          before(:each) do
            @event.recurrence_rules = ['FREQ=MONTHLY;INTERVAL=1;BYDAY=1MO']
            create_parser(@event)          
          end
          
          it "should return 12 dates" do
            @parser.dates(@range).size.should == 12
          end
          
          it "should return only Mondays" do
            # Garfield hates this recurrence rule.
            @parser.dates(@range).map {|d| d.wday == Runt::Monday}.all?.should be_true
          end
        end
      end
      
      context "with a five-year range" do
        before(:each) do
          @range = (Date.civil(2008, 12, 1)..(Date.civil(2013, 11, 30)))
        end
        
        context "recurring every year" do
          before do
            @event.recurrence_rules = ['FREQ=YEARLY;INTERVAL=1']
            create_parser(@event)
            @dates = @parser.dates(@range)
          end
          
          it "should return 5 dates" do
            @dates.size.should == 5
          end
          
          it "should return the correct date each year" do
            @dates.map do |d| 
              [:month, :day].map do |method|
                d.send(method) == @event.start.send(method)
              end.all?
            end.all?.should be_true
          end
        end
        
        context "recurring every other year" do
          before do
            @event.recurrence_rules = ['FREQ=YEARLY;INTERVAL=2']
            create_parser(@event)
            @dates = @parser.dates(@range)
          end
          
          it "should return 3 dates" do
            @dates.size.should == 3
          end
          
          it "should return the correct date each year" do
            @dates.map do |d| 
              [:month, :day].map do |method|
                d.send(method) == @event.start.send(method)
              end.all?
            end.all?.should be_true
          end
        end
        
        context "recurring every December and June" do
          before do
            @event.recurrence_rules = ['FREQ=YEARLY;INTERVAL=1;BYMONTH=6,12']
            create_parser(@event)
            @dates = @parser.dates(@range)
          end
          
          it "should return 10 dates" do
            @dates.size.should == 10
          end
        end
      end
    end
  end
end