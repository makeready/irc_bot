class RPNCalculator < Array

  def executecommand(operation)
    raise Exception, 'calculator is empty' unless self.size > 0
    case operation
    when :+
      calcval = self[-2] + self[-1]
    when :-
      calcval = self[-2] - self[-1]
    when :*
      calcval = self[-2] * self[-1]
    when :/
      calcval = self[-2] / self[-1].to_f
    end
    self.pop
    self.pop
    self << calcval
  end

  def plus
    executecommand(:+)
  end

  def minus
    executecommand(:-)
  end

  def times
    executecommand(:*)
  end

  def divide
    executecommand(:/)
  end

  def value 
    self[-1]
  end

  def tokens(eval_string) #converts an input string into an array of numbers and operation symbols
    operators = ["+","-","*","/"]
    output = []
    eval_string.split.each do |input|
      if operators.include?(input)
        output << input.to_sym
      else
        output << input.to_i
      end
    end
    output
  end

  def evaluate(eval_string) #executes a previously tokenized string
    input = tokens(eval_string)
    input.each do |item|
      if item.is_a? Fixnum
        self << item
      else
        begin
          executecommand(item)
        rescue Exception => emptymsg
          return "Error evaluating command " + emptymsg.to_s
        end
      end
    end
    value
  end
end