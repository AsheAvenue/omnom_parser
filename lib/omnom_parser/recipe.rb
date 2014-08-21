# encoding: utf-8

class Recipe
  attr_accessor :name, :yield, :prep_time, :cook_time, :total_time, :serving_size, :image_url, :ingredients, :instructions, :description, :word_count, :unrecognized_word_count
  
  def initialize
    @word_count = 0
    @unrecognized_word_count = 0
    @ingredients = Array.new #array of IngredientList objects
    @instructions = Array.new #array of strings
  end
  
  def is_empty?
    @ingredients.length == 0 && @instructions.length == 0 && self.name.to_s == '' && self.yield.to_s == '' && self.prep_time.to_s == '' && self.cook_time.to_s == '' && self.total_time.to_s == '' && self.serving_size.to_s == '' && self.description.to_s == ''
  end
  
end