require "socket"
require "./rpn_calculator"
require "./make_change"

server = "chat.freenode.net"
port = "6667"
name = "ReadyBot"
channel = "#bitmaker"
sys = "privmsg #{channel} :"
greeting = "readybot "

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
      tempcalc = RPNCalculator.new
      response = tempcalc.evaluate(command[8..-1]).to_s + "."

    elsif command[0..9].downcase == "makechange"
      response = "Here are your coins: " + Changer.make_change(command[11..-1]).to_s + "."

    elsif command == "help"
      response = "Valid commands are rpncalc, makechange, and help."

    else
      response = ("I don't understand \"#{command}\".")

    end
    
    response << " Why was I programmed to feel pain?" if rand(10) == 9 
    irc_server.puts "PRIVMSG #{channel} :#{response}"
  elsif msg.include? "ping"
    irc_server.puts msg.gsub("ping", "PONG")
    puts "pong"
  end
end
