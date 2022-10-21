using LinearAlgebra
using Graphs
using DataFrames
import CSV

# the hashmap creates a fast way to index letters
alphabet = "abcdefghijklmnopqrstuvwxyz"
ranked_alphabet = "qxjzvfwbkgpmhdcytlnuroisea"
ranked_ints = [findall(x->x==c, alphabet)[1] for c in ranked_alphabet]
a_dict = Dict{Char, Int}(diag([(c, words_tested) for c = alphabet, words_tested = 1:26]))

# reads list of 5 letter words and splits them into an array
println("Loading and processing words...")
words_beta = split(read(open("words_beta.txt", "r"), String), "\n")
words_beta_sets = [Set(word) for word in words_beta] # all words mapped to sets for later lookup

function tobit(string::AbstractString)
    blank = BitArray(zeros(26))
    for c in string
        blank[a_dict[c]] = 1
    end
    return blank
end

function toset(b::BitArray)
    set = Set()
    for i in 1:26
        if b[i] == 1
            push!(set, alphabet[i])
        end
    end
    return set
end

function possiblewords(word::Set)
    indices = findall(x -> x == word, words_beta_sets)
    return words_beta[indices]
end

emptyword() = BitArray(zeros(26))

sharechars(a::BitArray, b::BitArray) = 1 in (a .& b)

function sharechars(a::AbstractString, b::AbstractString)
    share = false
    for char in a
        if char in b
            share = true
            break
        end
    end
    return share
end

# map words to BitArrays, filter for duplicates, then filter for anagrams
words = filter(x -> length(findall(x)) == 5, collect(Set(map(tobit, words_beta))))

# sort by what letter in the alphabet they have
words_sub = []  # stores indices of words that have specific letters
words_tmp = copy(words)
for i in ranked_ints
    filtered = findall(x -> x[i] == 1, words_tmp)
    push!(words_sub, filtered)
    replace!(x -> x[i] == 1 ? emptyword() : x, words_tmp)  # replace already stored words with empty words
end

# start making possible lists
println("Making possible lists...")
possible_lists = [[i] for i in words_sub[1]]
# for word1=words_sub[1], j=2:length(words_sub), word2=words_sub[j]
#     if !sharechars(words[word1], words[word2])
#         push!(possible_lists, [word1, word2])
#     end
# end
for list in possible_lists, j in 2:26, test_word in words_sub[j]
    # checks that no words in list share letters with the test word
    compatible = (length(findall(x -> sharechars(words[x], words[test_word]), list)) == 0)
    if compatible
        push!(list, test_word)
    end
end

# filter!(x -> length(x) == 5, possible_lists)
println(possible_lists)


# creates a graph of all words and adds edges where words share no letters
# println("Generating graph...")
# graph = Graph(length(words))
# for i=1:(length(words_sub)), word1=words_sub[i], j=(i+1):length(words_sub), word2=words_sub[j]
#     if !sharechars(words[word1], words[word2])
#         add_edge!(graph, word1, word2)
#     end
# end

# # finds cliques and filters for cliques with five nodes
# println("Finding cliques...")
# cliques = clique_percolation(graph, k=5)
# # filter!(x -> length(x) == 5, cliques)

# # convert cliques into possible words
# println("Converting cliques to word combinations...")
# solutions = []
# for clique in cliques
#     clique_sets = [words[node] for node in clique]
#     solution = [possiblewords[word] for word in clique_sets]
#     push!(solutions, solution)
# end

# # convert solutions to a dataframe and store CSV
# println("Storing solutions in solutions.csv ...")
# df = DataFrame(A=solutions[1:end][1], B=solutions[1:end][2], C=solutions[1:end][3], 
#                 D=solutions[1:end][4], E=solutions[1:end][5])
# CSV.write("solutions.csv", df)

# println("Algorithm complete! :)")
