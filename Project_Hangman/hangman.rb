dictionary = File.readlines("dictionary.txt").map { |word| word.chomp }

class Hangman
	attr_reader :word_pool, :picked_word, :posted_word, :player
	
	def initialize(word_pool)
		@word_pool = word_pool
		@picked_word = pick_word_in_range((5..12)).split("")
		@posted_word = Array.new(picked_word.length, "_")
		@player = Player.new
	end
	
	def pick_word_in_range(num_of_letters)
		new_word_pool = word_pool.map do |word|
											word if num_of_letters.include? word.length
										end.compact
		new_word_pool[rand(new_word_pool.length)]
	end
	
	def check_for_strike(letter)
		player.strikes += 1 unless picked_word.include? letter
	end
	
	def post_word
		picked_word.each do |letter|
			if player.guesses.include? letter.downcase
				print letter + " "
			else
				print "_ "
			end
		end
	end
	
	def post_strikes
		print "#{player.strikes} of 5 strikes "
	end
	
	def post_guesses
		print "Guessed: "
		player.guesses.sort.each { |letter| print letter + " " }
	end
	
	def post_header
		post_word
		print "- "
		post_strikes
		print "- "
		post_guesses
		print "\n"
	end
	
	def play
		puts "Welcome to Hangman."
		post_word
		print "\n"
		until winner? || loser?
			letter = player.get_letter
			check_for_strike(letter)
			post_header
		end
		if winner?
			puts "You win! You guessed #{picked_word.join("")}."
		else
			puts "You lose! The word was #{picked_word.join("")}."
		end
	end

	def winner?
		picked_word.all? { |letter| player.guesses.include? letter }
	end

	def loser?
		player.strikes == 5 ? true : false
	end
end

class Player
	attr_reader :guesses
	attr_accessor :strikes
	
	def initialize
		@guesses = []
		@strikes = 0
	end
	
	def get_letter
		print "Please enter a letter:"
		letter = gets.chomp.downcase
		until (is_letter?(letter)) && (unguessed?(letter))
			print "Not a valid option, please try again:"
			letter = gets.chomp.downcase
		end
		add_to_guesses(letter)
		return letter
	end
	def add_to_guesses(letter)
		guesses << letter
	end
	def is_letter?(letter)
		(letter.length == 1) && (("a".."z").include? letter)
	end
	def unguessed?(letter)
		!(guesses.include? letter)
	end
	

end


hangman = Hangman.new(dictionary)
hangman.play