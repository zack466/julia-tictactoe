using UnicodePlots

function print_board(b::Matrix{Char})
    #for debugging, prints out internal game board matrix
    for i in 1:3
        for j in 1:3
            print(b[i,j])
            print(" ")
        end
        print("\n")
    end
    print("\n")
end

function clear_console()
    print("\033[2J\033[;H")
end

function plot_board(b::Matrix{Char})
    #prints out the game board plot
    clear_console()
    println(plt)
end

function plot_move(x::Int8, y::Int8, player::Char)
    # y and x are switched whoops
    if player == 'X'
        # draws a blue 'X'
        xsize = 0.7 #0 is largest, 1 is smallest
        lineplot!(plt,[3*y-3+xsize,3*y-xsize],[12-(3*x)-xsize,12-(3*x + 3)+xsize],color=:blue) #down-right diagonal
        lineplot!(plt,[3*y-3+xsize,3*y-xsize],[12-(3*x+3)+xsize,12-(3*x)-xsize],color=:blue) #up-right diagonal
    else
        # draws a green 'O'
        domain = (3*y - 2.5):0.2:(3*y-0.5)
        
        #top half of circle
        top = sqrt.(1 .- (domain .- 1.5 .- (3*y - 3)) .^ 2) .+ 1.35 .+ (6 - (3*x - 3)) 
        lineplot!(plt,domain,top,color=:green)
        
        #bottom half of circle
        bottom = -sqrt.(1 .- (domain .- 1.5 .- (3*y - 3)) .^ 2) .+ 1.35 .+ (6 - (3*x - 3)) 
        lineplot!(plt,domain,bottom,color=:green)
    end
end

function make_move(b::Matrix{Char},x::Int8,y::Int8,player::Char)
    #precondition: x, y are within array bounds
    b[x,y] = player #internal game board
    plot_move(x,y,player) #draws the move
end

function check_win(b::Matrix{Char},player::Char)
    #check all rows and columns
    for n in 1:3
        if all(c -> c == player, b[n,1:3])
            return true
        elseif all(c -> c == player, b[1:3,n])
            return true
        end
    end
    #check diagonals
    if all(c -> c == player, b[n,n] for n in 1:3)
        return true
    elseif all(c -> c == player, b[n,4-n] for n in 1:3)
        return true
    end
    #no win
    return false
end

function get_move(b::Matrix{Char})
    #gets and returns a valid move from the player
    while true
        try
            print("Make a move: ")
            input = parse.(Int8,split(chomp(readline())))
            x,y = input[2], input[1]
            @assert x in 1:3 && y in 1:3 #within array bounds
            @assert b[x,y] == '.' #space is empty
            return x,y
        catch ex
            println("Invalid move.")
            #print_board(b)
        end
    end
end

function play(b::Matrix{Char})
    clear_console()
    turn = Int8(0) #either 0 or 1, represents the turn
    while true
        #if tie
        if turn == 9
            plot_board(b)
            println("It's a tie!")
            break
        end
        
        #draws board
        plot_board(b)
        #determines whose turn it is
        player = turn % 2 == 0 ? 'X' : 'O'
        
        #gets moves
        moves = get_move(board)
        
        #game state is updated
        make_move(b,moves[1],moves[2],player)
        #check for a victory
        if check_win(b,player)
            plot_board(b)
            print(player); println(" wins!")
            break
        end

        #continue game
        turn += 1
    end
end

function game_setup()
    #creates internal game board
    global board = fill(Char('.'),(3,3))

    #BrailleCanvas, DotCanvas, BlockCanvas, or AsciiCanvas
    CANVAS = DotCanvas

    #Draws plot and boundary lines
    global plt = lineplot([3,3],[0,9],color=:white,xlim=[0,9],ylim=[0,9],labels=false,canvas=CANVAS,height=24,width=50)
    lineplot!(plt,[6,6],[0,9],color=:white)
    lineplot!(plt,[0,9],[3,3],color=:white)
    lineplot!(plt,[0,9],[6,6],color=:white)
end

#instructions
println("How to play: type in your move in the format 'column row' (ex: '2 3' for column 2 row 3).")
print("Press enter to continue... "); readline()

#setup and start game
game_setup(); play(board)

#loop
while true
    print("Would you like to play again? (y/n) "); input = chomp(readline())
    if input == "y"
        game_setup(); play(board)
    elseif input == "n"
        println("Thanks for playing!"); break
    end
end