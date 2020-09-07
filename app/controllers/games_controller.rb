# frozen_string_literal: true

require 'open-uri'
require 'json'
require 'byebug'

class GamesController < ApplicationController
  DICTIONARY_URL = 'https://wagon-dictionary.herokuapp.com/'

  private_constant :DICTIONARY_URL

  def new
    @letters = ('A'..'Z').to_a.sample(10)
    session[:letters] = @letters
    session[:start_time] = Time.now
  end

  def score
    ans = params[:answer]
    URI.open(DICTIONARY_URL + ans) do |res|
      res = JSON.parse(res.read)
      p res
      @result = if !res['found']
                  { score: 0, message: "#{ans} is not an not an english word" }
                elsif !in_grid?(ans)
                  { score: 0, message: "#{ans} is not in #{session[:letters].join(', ')}" }
                else
                  { score: calc_score(ans), message: 'Well done!' }
                end
    end
  end

  private

  def in_grid?(answer)
    letters = session[:letters].clone
    answer.upcase.chars.each_with_object(true) do |char, in_letters|
      break unless in_letters

      char_idx = letters.index(char)
      return false if char_idx.nil?

      letters.delete_at(char_idx)
    end
  end

  def calc_score(ans)
    elapsed = Time.now - session[:start_time].to_time
    ans.size * 10 - elapsed.to_i
  end
end
