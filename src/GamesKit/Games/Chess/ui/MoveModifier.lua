-- Stonetr03

return function (Piece: string,OldSqr: string,NewSqr: string)
    -- W King
    if Piece == "K" then
        if NewSqr == "h1" and OldSqr == "e1" then
            return "g1"
        elseif NewSqr == "a1" and OldSqr == "e1" then
            return "c1"
        elseif NewSqr == "b1" and OldSqr == "e1" then
            return "c1"
        end

    -- B King
    elseif Piece == "k" then
        if NewSqr == "h8" and OldSqr == "e8" then
            return "g8"
        elseif NewSqr == "a8" and OldSqr == "e8" then
            return "c8"
        elseif NewSqr == "b8" and OldSqr == "e8" then
            return "c8"
        end

    end
    return NewSqr
end
