= RruleParser

http://www.github.com/texel/recurrence-rule-parser

== DESCRIPTION:

This package takes icalendar events (or any object conforming to their calling conventions),
and handles translating recurrence rules into temporal expressions.

== FEATURES/PROBLEMS:

Current list of supported expressions:
FREQ, INTERVAL, BYDAY, BYMONTHDAY, UNTIL

Many values are still unimplemented.

== SYNOPSIS:

RruleParser should be able to consume any object acting like Icalendar::Event, containing
recurrence rules as specified by the iCalendar (RFC 2445) specification. For more information
on formatting of recurrence rules, visit http://www.kanzaki.com/docs/ical/rrule.html

== EXAMPLES:

  event       = Icalendar::Event.new
  event.start = Time.parse('12/1/2008 3pm')
  event.end   = Time.parse('12/1/2008 6pm')
  
  event.recurrence_rules = ["FREQ=WEEKLY;INTERVAL=1;COUNT=10"] 
  
  parser      = RruleParser.new(event)
  date_range  = Date.parse('11/30/2008')..Date.parse('1/1/2009')
  
  parser.dates(date_range)
  
  #=> [Mon, 01 Dec 2008, Mon, 08 Dec 2008, Mon, 15 Dec 2008, Mon, 22 Dec 2008, Mon, 29 Dec 2008]

== REQUIREMENTS:

requires Runt.
requires Icalendar and RSpec if you wish to run the specs.

== INSTALL:

sudo gem install texel-rrule-parser

== LICENSE:

(The MIT License)

Copyright (c) 2008 FIX

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
