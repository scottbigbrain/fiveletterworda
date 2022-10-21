@time begin

words_alpha_raw = open("words_alpha.txt", "r")
words_alpha = read(words_alpha_raw, String)

split_words = split(words_alpha, "\r\n")
filtered_words = filter(x -> length(x) == 5, split_words)
joined_words = join(filtered_words, "\n")

words_beta = open("words_beta.txt", "w")
write(words_beta, joined_words)

end
