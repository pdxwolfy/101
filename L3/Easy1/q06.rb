famous_words = 'seven years ago...'
famous_words = 'Four score and ' + famous_words
puts famous_words

famous_words = 'seven years ago...'
famous_words = "Four score and #{famous_words}"
puts famous_words

famous_words = 'seven years ago...'
famous_words.sub!(/^/, 'Four score and ')
puts famous_words
