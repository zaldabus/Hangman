class Hangman
  attr_accessor :guesser, :checker
  
  def initialize(guesser, checker)
    @guesser, @checker = guesser, checker
    @board = Board.new
    @turns = 8
  end
  
  def play
    puts "Welcome to Hangman!"
    until @turns == 0
      turn
      return winner if @board.won?
    end
    return loser
  end
  
  def turn
    @board.display
    puts "Guess a letter"
    letter_guess = gets.chomp
    if @board.possible_guesses.include?(letter_guess)
      if @board.answer.include?(letter_guess)
        @board.letter_match(letter_guess) 
      else
        @turns -= 1
        puts "Sorry! That letter is not included!"
        puts "You have #{@turns} guesses left!" unless @turns == 0
      end
    else
      puts "Sorry! That letter has already been guessed!"
    end
  end
  
  def winner
    @board.show_answer
    puts "Congratulations! You guessed the word!"
    play_again_prompt
  end
  
  def loser
    @board.show_answer
    puts "Sorry! You have no guesses left!"
    play_again_prompt
  end 
  
  def play_again_prompt
    puts "Play again? Y/N"
    users_choice = gets.chomp
    if users_choice.split("").first.upcase == "Y"
      Hangman.new(@guesser,ComputerPlayer.new).play 
    else
      puts "Thank you, have a nice day!"
    end
  end
end

class Board
  attr_accessor :possible_guesses, :answer
  
  def initialize
    @answer = ComputerPlayer.new.pick_word.split("")
    @board = generate_board
    @possible_guesses = ("a".."z").to_a
  end
  
  def generate_board
    @answer.map {"_"}
  end
  
  def display
    puts @board.join(" ")
  end
  
  def letter_match(letter_guess)
    @answer.each_index do |i|
      @board[i] = letter_guess if @answer[i] == letter_guess
    end
    @possible_guesses.delete(letter_guess)
  end
  
  def won?
    @board.all? {|letter| letter != "_"}
  end
  
  def show_answer
    puts @answer.join(" ")
  end
end

class HumanPlayer
  def initialize
    
  end
  
  def pick_word
    
  end
end

class ComputerPlayer
  def initialize
    @words = File.readlines("dictionary.txt").map(&:chomp)
  end
  
  def pick_word
    @words.sample
  end
end