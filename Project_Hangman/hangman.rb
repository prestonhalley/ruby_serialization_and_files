class Dictionary
	attr_reader :word_pool
	def initialize
		@word_pool = File.readlines("dictionary.txt").map { |word| word.chomp }
	end
end

class Player
	attr_accessor :guess, :guesses, :strikes
	def initialize
		@guess = ""
		@guesses = []
		@strikes = 6
	end
	
	def get_guess
		valid_guess = false
		until valid_guess
			new_guess = gets.chomp.downcase
			if (new_guess.length == 1) && (("a".."z").include? new_guess) && !(guesses.include? new_guess)
				valid_guess = true 
			else
				print "Invalid guess.  Please try again:"
			end
		end
		self.guess = new_guess
		guesses << guess
	end
end

class Hangman
	attr_reader :dictionary, :player, :screen, :picked_word
	
	def initialize(dictionary, player, screen)
		@dictionary = dictionary
		@player = player
		@screen = screen
		@picked_word = pick_word_in_range((5..9)).split("")
	end
	
	def pick_word_in_range(num_of_letters)
		new_word_pool = dictionary.word_pool.map do |word|
											word if num_of_letters.include? word.length
										end.compact
		new_word_pool[rand(new_word_pool.length)]
	end
	def get_guess
		screen.ask_for_letter
		player.get_guess
	end
	def winner?
		picked_word.all? { |letter| player.guesses.include? letter }
	end
	def loser?
		player.strikes == 0
	end
	def game_over?
		winner? || loser?
	end
	def analyze_guess
		unless (picked_word.include? player.guess.upcase) || (picked_word.include? player.guess.downcase)
			player.strikes -= 1 
		end
	end
	def play
		screen.post_word(picked_word, player.guesses)
		until game_over?
			get_guess
			analyze_guess
			screen.post_all(picked_word, player.strikes, player.guesses)
		end
		screen.post_winner(picked_word) if winner?
		screen.post_loser(picked_word) if loser?
	end
end

class Screen
	def ask_for_letter
		print "\nPlease select a letter:"
	end
	def post_word(word, guesses)
		word.each do |letter|
			if guesses.include? letter.downcase
				print letter + " "
			else
				print "_ "
			end
		end
	end
	def post_strikes(strikes)
		print "Chances left: #{strikes}"
	end
	def post_guesses(guesses)
		print "Letters Guessed: "
		guesses.sort.each { |letter| print letter + " " }
	end
	def post_all(word, strikes, guesses)
		post_word(word, guesses)
		print "- "
		post_strikes(strikes)
		print " - "
		post_guesses(guesses)
	end
	def post_winner(word)
		print "\nCongratulations! You guessed #{word.join("")}.\n"
	end
	def post_loser(word)
		print "\nI'm sorry. You couldn't guess #{word.join("")}.\n"
	end
end

hangman = Hangman.new(Dictionary.new, Player.new, Screen.new)
hangman.play