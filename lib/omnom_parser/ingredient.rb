# encoding: utf-8

class Ingredient
  attr_accessor :quantity, :unit, :name

  def self.range_indicator(string)
    matches = /( to |-|–)/.match(string)
    matches && matches[0]
  end

  def self.contains_numeric_values(ingredient_string)
    if ingredient_string
      words = ingredient_string.split
      numeric_words = words.select { |word| /[0-9]/.match(word) || word.in_numbers > 0 }
      numeric_words.size > 0
    else
      false
    end
  end

  def self.starts_with_numeric_value(ingredient_string)
    Ingredient.contains_numeric_values(ingredient_string.split.first)
  end
  
  def self.parse(ingredient_string)
    if ingredient_string.strip != ""
      ingredient = Ingredient.new
      ingredient_string = self.remove_vulgar_fractions(ingredient_string)

      # Only process if the ingredient string starts with a number
      if Ingredient.contains_numeric_values(ingredient_string.split.first)
        ingredient_string = self.first_word_to_number(ingredient_string)
        ingredient_string = self.convert_parentheticals(ingredient_string)
        ingredient_string = self.remove_non_finite_amounts(ingredient_string)
        
        result = Ingreedy.parse(ingredient_string.strip)
        ingredient.quantity = result.amount.round(2).to_s
        ingredient.unit = result.unit.to_s.singularize
        ingredient.name = result.ingredient   
      else
        ingredient.name = ingredient_string.downcase.strip
      end
      ingredient
    end
  end
  
  def self.first_word_to_number(ingredient_string)
    split_words = ingredient_string.split()
    if split_words.length > 0
      if ['one','two'].include? split_words[0].downcase
        split_words[0] = split_words[0].downcase.gsub(/(one|two)/,'one'=>'1','two'=>'2')
      end
      split_words.join(' ')
    else
      ingredient_string
    end
  end
  
  def self.convert_parentheticals(string)
    string.gsub!("(s)", "")
    string.gsub!("(es)", "")
    string
  end
  
  def self.remove_vulgar_fractions(string)
    string.gsub!(/[\s]*¼/, ".25")
    string.gsub!(/[\s]*½/, ".5")
    string.gsub!(/[\s]*¾/, ".75")
    string.gsub!(/[\s]*⅓/, ".33")
    string.gsub!(/[\s]*⅔/, ".67")
    string.gsub!(/[\s]*⅕/, ".2")
    string.gsub!(/[\s]*⅖/, ".4")
    string.gsub!(/[\s]*⅗/, ".6")
    string.gsub!(/[\s]*⅘/, ".8")
    string.gsub!(/[\s]*⅙/, ".17")
    string.gsub!(/[\s]*⅚/, ".83")
    string.gsub!(/[\s]*⅛/, ".13")
    string.gsub!(/[\s]*⅜/, ".38")
    string.gsub!(/[\s]*⅝/, ".63")
    string.gsub!(/[\s]*⅞/, ".88")
    string.gsub!(/([\d]+(\s+|\s*[-–]\s*))?([\d]+)\/([\d]+)/) {"#{$3.to_f / $4.to_f + $1.to_f}"}
    string
  end

  def self.strip_parens(string)
    string.gsub(/\([^)]*\)/, '')
  end
  
  def self.remove_non_finite_amounts(string)
    # Take the upper limit in an ingredient like "2 to 3 eggs"
    # Don't count "to's" found in parentheses (e.g. "7 ounces high-quality bittersweet (70 to 72% cacao) chocolate, finely chopped")

    # get a copy of the string without any parenthetical expressions
    string_without_parens = strip_parens(string)
    range_indicator = Ingredient.range_indicator(string_without_parens)
    to_index = range_indicator && 
               string_without_parens.index(range_indicator) && 
               string.index(range_indicator)
    if(to_index)

      # But don't do it if a comma is found before the range indicator (i.e. 'to' or a dash or a hyphen)
      comma_index = string.index(',')
      if !comma_index || comma_index > to_index
        amount_string = string.slice(string.index(range_indicator) + range_indicator.length, string.length).strip if Ingredient.contains_numeric_values(string_without_parens)
        string = amount_string if Ingredient.starts_with_numeric_value(amount_string)
      end
    end
    string
  end

  def remove_substring(string)
    self.name = self.name.gsub(/#{string}/i, '').strip if self.name
  end

  def blank?
    (self.quantity.nil? || self.quantity =~ /^[^[:graph]]*$/) && 
    (self.unit.nil? || self.unit =~ /^[^[:graph]]*$/) && 
    (self.name.nil? || self.name =~ /^[^[:graph]]*$/)
  end
end
