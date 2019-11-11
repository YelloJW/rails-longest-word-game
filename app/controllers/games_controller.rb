require 'json'
require 'open-uri'

class GamesController < ApplicationController
  def new
    alphabet = ('A'..'Z').to_a
    @letters = []
    10.times do
      @letters << alphabet.sample
    end
  end

  def score
    @grid = params[:letters]
    @word = params[:word]
    @word_found = check_word(@word)['found']
    @word_length = check_word(@word)['length']
    @can_build = can_build(@word, @grid)
    @message = build_message(@word, @grid, @can_build, @word_found)
    @score = session[:score] || 0
    if @word_found && @can_build
      @score += calculate_score(@word)[0]
      session[:score] = @score
      @word_score = calculate_score(@word)[0]
      @letter_scores = calculate_score(@word)[1]
    end
  end

  def check_word(word)
    url = "https://wagon-dictionary.herokuapp.com/#{word}"
    word_string = open(url).read
    JSON.parse(word_string)
  end

  def can_build(word, grid)
    # word_hash = Hash.new(0)
    # grid_hash = Hash.new(0)
    # word.chars.each { |letter| word_hash[letter.upcase] += 1 }
    # grid.chars.each { |letter| grid_hash[letter] += 1 }
    # word_hash.all? { |k, _v| word_hash[k] <= grid_hash[k] }
    word.upcase.chars.all? do |letter|
      word.chars.count(letter) <= grid.chars.count(letter)
    end
  end

  def build_message(word, grid, can_build, word_found)
    if !can_build
      @message = "Sorry but #{word} can't be built out of #{grid.chars.join(', ')}"
    elsif !word_found
      @message = "Sorry but #{word} does not seem to be a valid English word..."
    else
      @message = "Congratulations! #{word} is a valid English word!"
    end
  end

  def calculate_score(word)
    score = 0
    letter_scores = {}
    scores_hash = { "A": 1, "B": 3, "C": 3, "D": 2,
                    "E": 1, "F": 4, "G": 2, "H": 4,
                    "I": 1, "J": 8, "K": 5, "L": 1,
                    "M": 3, "N": 1, "O": 1, "P": 3,
                    "Q": 10, "R": 1, "S": 1, "T": 1,
                    "U": 1, "V": 4, "W": 4, "X": 8,
                    "Y": 4, "Z": 10 }
    word.chars.each do |letter|
      score += scores_hash[letter.upcase.to_sym]
      letter_scores[letter.upcase] = scores_hash[letter.upcase.to_sym]
    end
    [score, letter_scores]
  end
end
