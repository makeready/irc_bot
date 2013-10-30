require "socket"
require "./rpn_calculator"
require "./make_change"
require 'net/http'
require 'rexml/document'
require 'date'

server = "chat.freenode.net"
port = "6667"
name = "ReadyBot"
channel = "#bitmakerlabs"
sys = "privmsg #{channel} :"
greeting = "readybot "
nbakey = "ukesef6h6482qnf5azfdmpz6"
nbaurl = "http://api.sportsdatallc.org/nba-t3/games/2013/reg/schedule.xml?api_key=#{nbakey}"
todays_date = Date.today.to_s
response = ""
hometeam = ""
awayteam = ""

puts "Loading NBA schedule data..."

nbadata = Net::HTTP.get_response(URI.parse(nbaurl)).body

doc = REXML::Document.new(nbadata)

puts "Connecting to IRC..."
irc_server = TCPSocket.open(server, port)

irc_server.puts "USER readybot 0 * ReadyBot"
irc_server.puts "NICK #{name}"
irc_server.puts "JOIN #{channel}"





until irc_server.eof? do
  msg = irc_server.gets.downcase.strip
  puts msg

  if msg.include? sys and msg.include? (greeting.downcase)
    command = msg[msg.index(" :")+11..-1]
    puts command[0..9].downcase

    if command[0..6].downcase == "rpncalc"
      if command[-1] == "c" then
        response = "To use rpncalc try rpncalc followed by numbers and operators (+-/*) separated by spaces."
      elsif
        tempcalc = RPNCalculator.new
        response = tempcalc.evaluate(command[8..-1]).to_s + "."
      end

    elsif command[0..9].downcase == "makechange"
      if command[-1] == "e" then
        response = "To use makechange try makechange [number]."
      else
        response = "Here are your bills/coins: " + Changer.make_change(command[11..-1]).to_s + "."
      end

    elsif command[0..4] == "leave"
      response = "Insufficient permissions to force me to leave."

    elsif command[0..9] == "sudo leave"
      irc_server.puts "PRIVMSG #{channel} :wow fine"
      quit

    elsif command[0..2] == "nba"
      response = "Today's games: "
      doc.elements.each("league/season-schedule/games/game") do |game|
        if game.attributes["scheduled"][0..9] == todays_date
          game.elements.each do |element|
            hometeam = element.attributes["alias"] if element.name == "home"
            awayteam = element.attributes["alias"] if element.name == "away"
          end
          response << "#{awayteam} at #{hometeam}, "
        end
      end
      response.chop!.chop!
      response << "."
      response << " Go Raptors!" if response.include?("TOR")

    elsif command[0..2] == "nhl"
      response = "Hockey sure is an activity that people enjoy watching. I guess..."

    elsif command == "help"
      response = "Valid commands are rpncalc, makechange, nba, leave, and help."

    else
      response = ("I don't understand \"#{command}\".")
    end
    
    response << " Why was I programmed to feel pain?" if rand(10) == 9 
    irc_server.puts "PRIVMSG #{channel} :#{response}"
  elsif msg.include? "ping"
    irc_server.puts msg.gsub("ping", "PONG")
    puts "pong"
  elsif msg.include? "pong"
    irc_server.puts msg.gsub("pong", "PING")
    puts "ping"
  end
end
