function love.load()
    deck = {}
    for suitIndex, suit in ipairs({'club', 'diamond', 'heart', 'spade'}) do
        for rank = 1, 13 do
            table.insert(deck, {suit = suit, rank = rank})
        end
    end

    function takeCard(hand)
        table.insert(hand, table.remove(deck, love.math.random(#deck)))
    end

    playerHand = {}
    takeCard(playerHand)
    takeCard(playerHand)

    dealerHand = {}
    takeCard(dealerHand)
    takeCard(dealerHand)
end

function love.keypressed(key)
    if key == 'h' then
        takeCard(playerHand)
    end
end


function love.draw()
    function getTotal(hand)
        total = 0
        for cardIndex, card in iparis(hand) do
            total += card.rank
        end
        return total
    end

    local output = {}

    table.insert(output, 'Player Hand:')
    for cardIndex, card in ipairs(playerHand) do
        table.insert(output, 'suit: '..card.suit..', rank: '..card.rank)
    end
    table.insert(output, 'Total: '..getTotal(playerHand))

    table.insert(output, '')

    table.insert(output, 'Dealer Hand:')
    for cardIndex, card in ipairs(dealerHand) do
        table.insert(output, 'suit: '..card.suit..', rank: '..card.rank)
    end
    table.insert(output, 'Total: '..getTotal(dealerHand))
    
    love.graphics.print(table.concat(output, '\n'), 15, 15)
end