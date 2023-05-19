function love.load()
    Deck = {}    
    DeckCount = 4
    for i=1,DeckCount do
        for suitIndex, suit in ipairs({'club', 'diamond', 'heart', 'spade'}) do
            for rank = 1, 13 do
                table.insert(Deck, {suit = suit, rank = rank})
            end
        end
    end

    function TakeCard(hand)
        table.insert(hand, table.remove(Deck, love.math.random(#Deck)))
    end

    function HasAce(hand)
        for cardIndex, card in ipairs(hand) do
            if card.rank == 1 then
                return true
            end
        end 
        return false
    end

    print(#Deck)

    PlayerHand = {}
    takeCard(PlayerHand)
    takeCard(PlayerHand)

    DealerHand = {}
    takeCard(DealerHand)
    takeCard(DealerHand)

    RoundOver = false
end

function love.keypressed(key)
    if not RoundOver then
        if key == 'h' then
            takeCard(PlayerHand)
            if GetTotal(PlayerHand) >= 21 then
                RoundOver = true
            end
        elseif key == 's' then
            RoundOver = true
        end
    else
        love.load()
    end
end

function love.draw()
    function GetTotal(hand)
        local total = 0
        local highAce = false

        for cardIndex, card in ipairs(hand) do
            if card.rank > 10 then
                total = total + 10
            elseif card.rank == 1 then
                if total < 11 then
                    total = total + 11
                    highAce = true
                else
                    total = total + 1
                end
            else
                total = total + card.rank
            end
        end

        if total > 21 and highAce then
            total = total - 10
            highAce = false    
        end

        return total
    end

    local output = {}

    table.insert(output, 'Player Hand:')
    for cardIndex, card in ipairs(PlayerHand) do
        table.insert(output, 'suit: '..card.suit..', rank: '..card.rank)
    end
    table.insert(output, 'Total: '..GetTotal(PlayerHand))

    table.insert(output, '')

    table.insert(output, 'Dealer Hand:')
    for cardIndex, card in ipairs(DealerHand) do
        if not RoundOver and cardIndex == 1 then
            table.insert(output, '(Card hidden)')
        else
            table.insert(output, 'suit: '..card.suit..', rank: '..card.rank)
        end        
    end       

    if RoundOver then
        table.insert(output, 'Total: '..GetTotal(DealerHand))
        while GetTotal(DealerHand) <= 17 and GetTotal(PlayerHand) < 21 do
            if GetTotal(DealerHand) == 17 and not HasAce(DealerHand) then
                break
            else
                takeCard(DealerHand)
            end
        end

        table.insert(output, '')

        local function hasThisHandWon(thisHand, otherHand)
            return GetTotal(thisHand) <= 21 and
            (GetTotal(otherHand) > 21 or GetTotal(otherHand) < GetTotal(thisHand))
        end

        if hasThisHandWon(PlayerHand, DealerHand) then
            table.insert(output, 'Player Wins!')
        elseif hasThisHandWon(DealerHand, PlayerHand) then
            table.insert(output, 'Dealer Wins!')
        else 
            table.insert(output, "Draw!")
        end
    else
        table.insert(output, 'Total: ')
    end

        love.graphics.print(table.concat(output, '\n'), 15, 15)
end