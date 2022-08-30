module Saves
  def save_game
    Dir.mkdir 'output' unless Dir.exist? 'output'
    puts "\nname your save file:" ; name = gets.chomp
    @filename = "#{name}_game.yaml"
    File.open("output/#{@filename}", 'w') { |file| file.write save_to_yaml }
  end

  def save_to_yaml
    YAML.dump(
      'word' => @word,
      'guesses_remaining' => @guesses_remaining,
      'answer' => @answer,
      'correct' => @correct,
      'incorrect' => @incorrect,
      'game_over' => @game_over
    )
  end

  def find_saved_file
    show_file_list
    puts "Load which game? or type 'exit'"
    file_number = gets.chomp
    @saved_game = file_list[file_number.to_i - 1] unless file_number == 'exit'
  end

  def show_file_list
    puts "# File Name(s)"
    file_list.each_with_index do |name, index|
      puts "#{(index + 1).to_s} #{name.to_s}"
    end
  end

  def file_list
    files = []
    Dir.entries('output').each do |name|
      files << name if name.match(/(game)/)
    end
    files
  end

  def load_saved_file
    file = YAML.safe_load(File.read("output/#{@saved_game}"))
    @word = file['word']
    @guesses_remaining = file['guesses_remaining']
    @answer = file['answer']
    @correct = file['correct']
    @incorrect = file['incorrect']
    @game_over = file['game_over']
  end
end
