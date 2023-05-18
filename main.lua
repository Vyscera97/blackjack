-- Create Deck of cards using dictionary (Deck) where each card is table w/a suit & num
function love.load()
    deck = {}
    for suitIndex, suit in ipairs({'club', 'diamond', 'heart', 'spade'}) do
        for rank = 1, 13 do
            table.insert(deck, {suit = suit, rank = rank})
            print('suit: '..suit..', rank: '..rank)
        end
    end
    print('cards in deck: '..#deck)
end
