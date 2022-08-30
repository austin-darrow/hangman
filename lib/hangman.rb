require_relative 'saves'
require 'yaml'

class Game
  attr_accessor :word, :guesses_remaining, :answer, :correct, :incorrect, :game_over

  include Saves

  def initialize
    Display.new.clear_console
    @word = Word.new.generate_word
    @answer = []
    @correct = []
    @incorrect = []
    @guesses_remaining = @word.length
    @game_over = false
    game_type()
  end

  def play_game
    Display.new.update_display(@answer, @correct, @incorrect, @guesses_remaining)
    while @game_over == false
      play_round()
      game_over?()
    end
  end

  def play_round
    guess = Player.new.guess_letter(@correct, @incorrect)
    if guess == "1"
      save_game
      Game.new
    end
    check_answer(guess)
    update_answer()
    Display.new.update_display(@answer, @correct, @incorrect, @guesses_remaining)
  end

  def game_type
    puts "Welcome to hangman!"
    puts "Press [1] to start a new game"
    puts "Press [2] to load a saved game"
    input = gets.chomp.to_i
    play_game if input == 1
    load_game if input == 2
  end

  def load_game
    find_saved_file()
    load_saved_file()
    play_game()
  end

  private

  def check_answer(guess)
    if @word.include?(guess)
      @correct.push(guess) unless @correct.include?(guess)
    else
      unless @incorrect.include?(guess)
        @incorrect.push(guess)
        @guesses_remaining -= 1
      end
    end
  end

  def update_answer
    @answer = []
    @word.split('').each do |c|
      if @correct.include?(c)
        @answer.push(c)
      else
        @answer.push("_")
      end
    end
  end

  def game_over?
    if @answer.none?("_")
      puts "You win!"
      @game_over = true
      play_again?()
    elsif @guesses_remaining == 0
      puts "No guesses remaining. You lose."
      @game_over = true
      play_again?()
    end
  end

  def play_again?
    puts "\nPlay again? 'y' or 'n'"
    answer = gets.chomp.downcase
    if answer == 'y'
      Game.new.play_game
    else
      puts "\nThanks for playing!"
    end
  end
end

class Player
  def guess_letter(correct, incorrect)
    puts "What letter would you like to guess? (enter 1 to save)"
    letter = gets.chomp.downcase
    if letter == "1"
      return "1"
    end
    if correct.include?(letter) || incorrect.include?(letter)
      puts "You've already guessed that. Please try a new guess:"
      guess_letter(correct, incorrect)
    elsif letter.match?(/[^A-Za-z]/)
      puts "Invalid guess. Please enter a letter:"
      guess_letter(correct, incorrect)
    end
    letter.downcase
  end
end

class Display
  def update_display(answer, correct, incorrect, guesses_remaining)
    clear_console()
    puts answer.join(" ") + "\n\n"
    # puts "Correct letters:   #{correct.sort.join(" ")}"
    puts "Incorrect letters: #{incorrect.sort.join(" ")}"
    puts "Guesses remaining: #{guesses_remaining}"
    puts ''
  end

  def clear_console
    puts %x(/usr/bin/clear)
  end
end

class Word
  def generate_word
    all_words = File.read('google-10000-english-no-swears.txt').split("\n")
    potential_words = all_words.select { |word| word.length > 4 && word.length < 13 }
    word = potential_words.sample
  end
end

Game.new
