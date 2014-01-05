class Hangman
  def initialize(guesser, checker)
    @guesser, @checker = guesser, checker
    @board = Board.new(@checker.word_length)
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
    letter_guess = @guesser.guesses_letter(@board.board)
    if @board.possible_guesses.include?(letter_guess)
      puts "Is it #{letter_guess}? Y/N" if @guesser.is_a?(ComputerPlayer)
      if @checker.confirm_guess(letter_guess)
        @checker.marks_guess(@board.board, letter_guess) 
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
    @checker.is_a?(ComputerPlayer) ? @checker.show_answer : @board.display
    puts "Congratulations! You guessed the word!"
    play_again_prompt
  end
  
  def loser
    @checker.is_a?(ComputerPlayer) ? @checker.show_answer : @board.display
    puts "Sorry! You have no guesses left!"
    play_again_prompt
  end 
  
  def play_again_prompt
    puts "Play again? Y/N"
    users_choice = gets.chomp
    if users_choice.split("").first.upcase == "Y"
      if @checker.is_a?(ComputerPlayer)
        Hangman.new(HumanPlayer.new, ComputerPlayer.new).play 
      else
        Hangman.new(ComputerPlayer.new, HumanPlayer.new).play
      end 
    else
      puts "Thank you, have a nice day!"
    end
  end
end

class Board
  attr_accessor :possible_guesses, :answer, :board
  
  def initialize(board_length)
    @board = generate_board(board_length)
    @possible_guesses = ("a".."z").to_a
  end
  
  def generate_board(board_length)
    board_length.times.map {"_"}
  end
  
  def display
    puts @board.join(" ")
  end
  
  def won?
    @board.all? {|space| space != "_"}
  end
end

class HumanPlayer
  def pick_word
    puts "Enter the length of your word:"
    Integer(gets.chomp)
  end
  
  def word_length
    pick_word
  end
  
  def guesses_letter(board)
    puts "Guess a letter"
    gets.chomp
  end
  
  def confirm_guess(letter_guess)
    response = gets.chomp
    response.split("").first.upcase == "Y" ? true : false
  end
  
  def marks_guess(board, letter_guess)
    puts "What positions?"
    positions = gets.chomp.split(",").map {|num| num.to_i.pred}
    positions.each {|i| board[i] = letter_guess}
  end
end

class ComputerPlayer
  attr_accessor :answer
  
  def initialize
    @guesses = ComputerAI.new
    @answer = pick_word
  end
  
  def pick_word
    File.readlines("dictionary.txt").map(&:chomp).sample
  end
  
  def word_length
    @answer.length
  end
  
  def guesses_letter(board)
    @guesses.word_length_filter(board.length)
    @guesses.guessed_word_filter(board)
    @guesses.highest_freq_letter_filter
  end
  
  def confirm_guess(letter_guess)
    formated_guess = letter_guess.downcase
    @answer.include?(formated_guess)
  end
  
  def marks_guess(board, letter_guess)
    board.each_index {|i| board[i] = letter_guess if @answer[i] == letter_guess}
  end
  
  def show_answer
    puts @answer.split("").join(" ")
  end
end

class ComputerAI
  def initialize
    @dictionary = File.readlines("dictionary.txt").map(&:chomp)
    @possible_guesses = ("a".."z").to_a
  end
  
  def word_length_filter(board_length)
    @dictionary.select! {|word| word.length == board_length}
  end
  
  def guessed_word_filter(board)
    board.each_with_index do |letter, i|
      if letter != "_"
        @dictionary.select! {|word| word.split("")[i] == letter}
      end
    end
    @dictionary
  end
  
  def highest_freq_letter_filter
    letter_freq = Hash.new(0)
    
    @dictionary.each do |word|
      word.split("").each {|letter| letter_freq[letter] += 1}
    end
    
    letter_count = letter_freq.sort_by {|letter, count| count}
    letter = letter_count.pop[0]
    
    until @possible_guesses.include?(letter)
      letter = letter_count.pop[0]
    end
    
    @possible_guesses.delete(letter)
    letter
  end
end