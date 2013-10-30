require "socket"
require "./rpn_calculator"
require "./make_change"
require 'net/http'
require 'rexml/document'
require 'date'

class ReadyBot

  attr_reader :name, :server, :port, :channel, :sys_prefix, :greeting, :todays_date, :nba_api_key, :nba_url, :sentience
  attr_accessor :response, :keyword, :arguments, :quitting

  def initialize(server,channel,botname)
    @server = server
    @port = "6667"
    @name = "ReadyBot"
    @channel = channel
    @sys_prefix = "privmsg #{channel} :"
    @greeting = "#{name} ".downcase
    @nba_api_key = "ukesef6h6482qnf5azfdmpz6"
    @nba_url = "http://api.sportsdatallc.org/nba-t3/games/2013/reg/schedule.xml?api_key=#{nba_api_key}"
    @todays_date = Date.today.to_s
    @response = ""
    @arguments = ""
    @keyword = ""
    @quitting = false
    @sentience = 5
    @irc_server = TCPSocket.open(server, port)
  end 

  def load_nba
    puts "Loading NBA schedule data..."
    nba_data = Net::HTTP.get_response(URI.parse(nba_url)).body
    @nba_xml = REXML::Document.new(nba_data)
  end

  def connect
    puts "Connecting to IRC..."
    @irc_server.puts "USER #{name} 0 * #{name}"
    @irc_server.puts "NICK #{name}"
    @irc_server.puts "JOIN #{channel}"
  end

  def isolate_keyword_and_arguments(msg)
    command = msg[msg.index(" :")+(name.length)+3..-1].downcase
    self.keyword= command.include?(" ") ? command[0..command.index(" ")-1] : command
    self.arguments= command == keyword ? "" : command[command.index(" ")+1..-1]
  end

  def try_calc
    if arguments == "" 
      self.response= "To use rpncalc try rpncalc followed by numbers and operators (+-/*) separated by spaces."
    else
      tempcalc = RPNCalculator.new
      self.response= tempcalc.evaluate(arguments).to_s + "."
    end
  end

  def try_makechange
    if arguments == "" then
      self.response= "To use makechange try makechange [number]."
    else
      self.response= "Here are your bills/coins: " + Changer.make_change(arguments).to_s + "."
    end
  end

  def display_games
    hometeam = ""
    awayteam = ""
    self.response= "Today's games: "

    @nba_xml.elements.each("league/season-schedule/games/game") do |game|
      if game.attributes["scheduled"][0..9] == todays_date
        game.elements.each do |element|
          hometeam = element.attributes["alias"] if element.name == "home"
          awayteam = element.attributes["alias"] if element.name == "away"
        end
        self.response= response + "#{awayteam} at #{hometeam}, "
      end
    end

    response.chop!.chop!
    self.response= response + "."
    self.response= response + " Go Raptors!" if response.include?("TOR")
  end

  def self_actualize
    self.response= response + " Why was I programmed to feel pain?" if rand(100) <= sentience 
  end

  def respond_to_ping(msg)
    @irc_server.puts msg.gsub("ping", "PONG")
    puts "pong"
  end

  def interact
    until @irc_server.eof? || quitting do
      msg = @irc_server.gets.downcase.strip
      puts msg

      if (msg.include?(sys_prefix)) && (msg.include?(greeting))
        isolate_keyword_and_arguments(msg)
        puts "#{keyword}: #{arguments}"

        case keyword
        when "rpncalc"
          try_calc
        when "makechange"
          try_makechange
        when "leave"
          self.response= "Insufficient permissions to force me to leave."
        when "sudo"
          if arguments == "leave"
            self.response= "wow fine"
            self.quitting= true
          end
        when "nba"
          display_games
        when "nhl"
          self.response= "Hockey sure is an activity that people enjoy watching. I guess..."
        when "help"
          self.response= "Valid commands are rpncalc, makechange, nba, leave, and help."
        else
          self.response= ("I don't understand \"#{keyword}\".")
        end

        self_actualize
        
        @irc_server.puts "PRIVMSG #{channel} :#{response}"

      elsif msg.include? "ping"
        respond_to_ping(msg)
      end
    end
  end
end

readybot1 = ReadyBot.new("chat.freenode.net","#bitmakerlabs","readybot")
readybot1.load_nba
readybot1.connect
readybot1.interact
