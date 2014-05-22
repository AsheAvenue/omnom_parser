# encoding: utf-8

class Technique

  def self.strip_parens(string)
    string.gsub(/\([^)]*\)/, '')
  end

  def self.numeralize_range(string, delimiter = ' to ', position = :last)
    tokens = string.split(delimiter)
    number_string = position == :last ? tokens.last : tokens.first
    if number_string.to_i == 0
      if number_string.in_numbers == 0
        string
      else
        number_string.in_numbers
      end
    else
      number_string.to_i
    end
  end

  def self.replace_ranges(string, position = :last)
    matches = string.scan(/[-.\w]* to [-.\w]*/)
    matches.each do |match|
      string.gsub!(match, numeralize_range(match).to_s)
    end

    matches = string.scan(/\d+\.?\d*\s*-\s*\d+\.?\d*/)
    matches.each do |match|
      string.gsub!(match, numeralize_range(match, '-').to_s)
    end

    string
  end
  
  def self.text(node, strategy)
    # we could benefit by extracting the "val" object to its own class
    if node
      val = node.try(:text) || node
      val.gsub!(/\s+/, " ")
      val.strip!

      #remove a substring
      if strategy['remove_substring']
        val = val.gsub(strategy['remove_substring'], '').strip
      end
      
      #convert to specific type
      if strategy['type'] == 'integer'
        multiply = false

        # strip parenthesized expressions
        val = strip_parens(val)

        val = Ingredient.remove_vulgar_fractions(val)  # should extract this method into a module

        # replace ranges with single integers
        val = replace_ranges(val)

        # get an array of all words (including the hyphen, for numbers)
        words = val.scan /[\w]+/

        # get us out of here unless there is a single numeric word
        words.map! do |word|
          if word.to_i == 0
            if word.in_numbers == 0
              word
            else
              word.in_numbers
            end
          else
            word.to_i
          end
        end
        words.select! { |word| word.kind_of?(Numeric) }
        return '' if words.size < 1

        if words.size > 1 and strategy['math'] == 'add'
          return words.sum{ |word| word.to_i }.to_s
        end

        val = case
        when val.index('to')
          val.slice(0..(val.index('to')))
        when val.index('-')
          val.slice(0..(val.index('-')))
        when val.index('–')
          val.slice(0..(val.index('–')))
        when val.index('+')
          val.slice(0..(val.index('+')))
        when val.index('(')
          val.slice(0..(val.index('(')))
        else
          val
        end

        if val.downcase.include? "dozen"
          multiply = (val.downcase.include? "half") ? 6 : 12
        end
        val_as_integer = val.gsub(/[^0-9 .]/i, '').to_i
        if multiply
          val_as_integer = val_as_integer * multiply
        end
        val = val_as_integer != 0 ? "#{val_as_integer}" : ''
      end
    else
      val = ''
    end
    val
  end
  
  def self.select(node, strategy)
    if node
      if node.attr(strategy['attribute'])
        node.attr(strategy['attribute']).gsub(/\s+/, " ").strip
      else
        ''
      end
    else
      ''
    end
  end
  
  def self.pt(node, strategy)
    if node
      start = node.attr(strategy['attribute']).gsub("PT", "").gsub("M", "").downcase.strip
      if start.include? "h"
        vals = start.split("h")
        val = "#{(vals[0].to_f * 60).to_i + vals[1].to_i}"
      else
        val = start
      end
    else
      val = ''
    end
  end
  
  def self.hour_minute(node, strategy)
    if node
      val = node.try(:text) || node
      val.gsub!(/\s+/, " ")
      val.strip!

      start = val.downcase.gsub(/\s+/, "").gsub("min", "").strip
      vals = start.split("hr")

      if vals.size > 1  # i.e. X hr(s) Y (mins)
        # strip non-numeric, non-'.' characters and convert to integers to calculate total time
        val = "#{(vals[0].gsub(/[^0-9.]/, '').to_i * 60) + (vals[1] ? vals[1].gsub(/[^0-9.]/, '').to_i : 0)}"
      else              # i.e. X (hr|min)
        val = vals[0].gsub(/[^0-9.]/, '').to_i
        val *= 60 if start.index('hr')
        val.to_s
      end
    else
      val = ''
    end
  end
  
  def self.ingredients(nodes)
    values = []
    if nodes.is_a? Array
      nodes.each do |node|
        if(!node.gsub(/\s+/, " ").strip.empty?)
          values.push Ingredient.parse(node.gsub(/\s+/, " "))
        end
      end
    else
      nodes.each do |node|
        if(!node.text.gsub(/\s+/, " ").strip.empty?)
          values.push Ingredient.parse(node.text.gsub(/\s+/, " "))
        end
      end
    end
    values
  end
  
  def self.all(nodes)
    values = []
    nodes.each do |node|
      val = node.text.gsub(/\s+/, " ").strip
      if val != ""
        values.push val
      end
    end
    values
  end
  
  def self.all_with_breaks(nodes)
    values = []
    nodes.each do |node|
      values << node.text.gsub(/\s+/, " ").strip
    end
    values.join("\n\n")
  end
  
  def self.split_by_breaks(node)
    values = []
    if node
      rawValues = node.inner_html.split('<br>')
      rawValues.each do |rawVal|
        values << Nokogiri::HTML(rawVal).text.strip
      end
    end
    values
  end
  
  def self.time_in_minutes(node)
    (ChronicDuration.parse(node.text.strip) / 60).to_s
  end
end