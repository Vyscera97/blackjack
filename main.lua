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

    roundOver = false
end

function love.keypressed(key)
    if key == 'h' and not roundOver then
        takeCard(playerHand)
    elseif key == 's' then
        roundOver = true
    end
end

function love.draw()
    local function getTotal(hand)
        local total = 0
        local hasAce = false

        for cardIndex, card in ipairs(hand) do
            if card.rank > 10 then
                total = total + 10
            else
                total = total + card.rank
            end

            if card.rank == 1 then 
                hasAce = true
            end
        end

        if hasAce and total < 12 then
            total = total + 10
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

    if roundOver then
        table.insert(output, '')

        if getTotal(playerHand) > getTotal(dealerHand) then
            table.insert(output, 'Player Wins!')
        elseif getTotal(dealerHand) > getTotal(playerHand) then
            table.insert(output, 'Dealer Wins!')
        else 
            table.insert(output, "Draw!")
        end

        love.graphics.print(table.concat(output, '\n'), 15, 15)
end