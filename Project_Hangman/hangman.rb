require 'yaml'

class Game
  attr_accessor :player, :word, :dictionary, :saves, :save_used, :saved
  def initialize
    @saves = YAML.load(File.read("saved_games.yaml"))
    if @save.class == String
      @saves = [] << @saves 
    else
      @saves = @saves.to_a
    end
    @save_used = nil
    @saved = false
    @player = Player.new
    @dictionary = Dictionary.new
    @word = pick_word_in_range(5..9).split("")
  end
  
  class Player
    attr_accessor :entry, :guesses, :strikes
    def initialize
      @entry = ""
      @guesses = []
      @strikes = 6
    end
  end
  
  class Dictionary
    attr_reader :word_pool
    def initialize
      @word_pool = File.readlines("dictionary.txt").map { |word| word.chomp }
    end
  end
  
  def pick_word_in_range(num_of_letters)
    new_word_pool = dictionary.word_pool.map do |word|
				      word if num_of_letters.include? word.length
				    end.compact
    new_word_pool[rand(new_word_pool.length)]
  end
  
  class Save
    attr_accessor :word, :guesses, :strikes
    def initialize(word, guesses, strikes)
      @word = word
      @guesses = guesses
      @strikes = strikes
    end
  end
  
  def post
    word.each do |letter|
      if player.guesses.include? letter.downcase
        print letter + " "
      else
        print "_ "
      end
    end
    print "| #{player.strikes} strikes left | Letters guesses:"
    player.guesses.sort.each { |letter| print " " + letter}
  end
  
  def get_entry
    valid_entry = false
    until valid_entry
      print "\nEnter letter: "
      entry = gets.chomp.downcase
      if (entry.length == 1) && (("a".."z").include? entry) && !(player.guesses.include? entry)
        valid_entry = true
      elsif entry == "save"
        valid_entry = true
      else
        print "Invalid entry!"
      end
    end
    player.entry = entry
  end

  def analyze
    if ("a".."z").include? player.entry
      player.guesses << player.entry
      unless word.include? player.entry
        player.strikes = player.strikes - 1
      end
    else
      save_game
      self.saved = true
    end
    YAML.load("saved_games.yaml")
  end

  def winner?
    word.all? { |letter| player.guesses.include? letter}
  end

  def loser?
    player.strikes == 0
  end

  def game_over?
    winner? || loser? || saved
  end

  def play
    until game_over?
      post
      get_entry
      analyze
    end
    print "You Win!\n" if winner?
    print "You Lose!\n" if loser?
    if saved
      print "Game Saved!\n"
    else
      if save_used
        saves.delete_at(save_used)
        File.open("saved_games.yaml", "w").write(YAML.dump(saves))
      end
    end
  end
  
  def save_game
    save = Save.new(word, player.guesses, player.strikes)
    if save_used
      saves[save_used] = save
    else
      saves << save
    end
    File.open("saved_games.yaml", "w").write(YAML.dump(saves))
  end

  def use_save?
    print "\nWould you like to 'load' a saved game or start a 'new' game?\n"
    answer = gets.chomp.downcase
    until answer == "load" || answer == "new"
      print "Please enter 'load' or 'new'.\n"
      answer = gets.chomp.downcase
    end
    if answer == "load"
      return true
    else
      return false
    end
  end

def select_save
  saves.each_with_index do |item, num|
    print "#{num+1}. "
    item.word.each do |letter|
      if item.guesses.include? letter.downcase
        print letter + " "
      else
        print "_ "
      end
    end
    print "| #{item.strikes} strikes left | Letters guesses:"
    item.guesses.sort.each { |letter| print " " + letter}
    print "\n"
  end
  print "Please select a saved game to play: "
  selection = gets.chomp.to_i
  until (selection <= saves.length) && (selection > 0)
    print "Please select a valid saved game: "
    selection = gets.chomp.to_i
  end
self.save_used = selection - 1
self.word = saves[save_used].word
player.strikes = saves[save_used].strikes
player.guesses = saves[save_used].guesses
end
def run
  print "Welcome to Hangman!\n"
  unless saves.empty?
    if use_save?
      select_save
    end
  end
  play
end
end

Game.new.run