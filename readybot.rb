require "socket"
require "./rpn_calculator"

server = "chat.freenode.net"
port = "6667"
name = "ReadyBot"
channel = "#bitmaker"
greeting_prefix = "privmsg #{channel} :"
greeting = "readybot "

irc_server = TCPSocket.open(server, port)

irc_server.puts "USER readybot 0 * ReadyBot"
irc_server.puts "NICK #{name}"
irc_server.puts "JOIN #{channel}"

until irc_server.eof? do
  msg = irc_server.gets.downcase
  puts msg

  wasGreeted = false
  wasGreeted = true if msg.include? (greeting.downcase)

  if msg.include? greeting_prefix and wasGreeted
    command = msg[msg.index(" :")+11..-1].chomp
    if command[0..6].downcase == "rpncalc"
      tempcalc = RPNCalculator.new
      response = tempcalc.evaluate(command[8..-1]).to_s + "."
    elsif command == "help"
      response = "Valid commands are rpncalc, help."
    else
      response = ("I don't understand \"#{command}\".")
    end
    response << " Why was I programmed to feel pain?" if rand(10) == 9 
    irc_server.puts "PRIVMSG #{channel} :#{response}"
  end
end
