class Game
  DEBUG = true

  def initialize
    @board = ["0", "1", "2", "3", "4", "5", "6", "7", "8"]
    @hum = "O" # the user's marker / Player 1
    @com = "X" # the computer's marker / Player 2
    @Jogo_Tipo = ['Humano vs CPU', 'CPU vs CPU', 'Humano vs Humano']
    @Jogo_Level = ['Fácil', 'Médio', 'Dificil']
    @nivel_dificuldade = 2
  end

  def print_board
    puts " #{@board[0]} | #{@board[1]} | #{@board[2]} \n===+===+===\n #{@board[3]} | #{@board[4]} | #{@board[5]} \n===+===+===\n #{@board[6]} | #{@board[7]} | #{@board[8]} \n"
  end
  
  def print_board_humanvshuman(tipo_jogo, jogador)
    puts "\n\nÉ a vez do Player #{jogador}"
    print_board
    if (tipo_jogo != 1) #Se só estão jogando computadores não precisa 
      puts "Enter [0-8]:"
    end
  end
  
  def clean_board
    @board = ["0", "1", "2", "3", "4", "5", "6", "7", "8"]
  end
    
  def entre_com_uma_opcao(pinMin, pinMax)
    begin
      escolha = gets.chomp
      puts "Escolheu:" + escolha.to_s
      begin
       escolha = Integer(escolha)
       if !(escolha >= pinMin && escolha <= pinMax)
          puts "Opção fora dos limites permitidos: #{pinMin} e #{pinMax}!"
          escolha = nil
       end
      rescue ArgumentError, TypeError
       puts "Escolha uma opção válida!"
       escolha = nil
      end
    end until escolha != nil
    return escolha
  end
  
  def getGameType
    puts "Escolha Tipo de Jogo:\n  0 - Humano vs CPU\n  1 - CPU vs CPU\n  2 - Humano vs Humano\n  3 - Sair\n"  
    puts "Enter [0-3]:"
    escolha = nil    
    escolha = entre_com_uma_opcao(0,3)
    if (escolha > 2)
      puts "Obrigado volte sempre!"
      exit
    end
    puts "Você escolheu a opção '" + @Jogo_Tipo[escolha].to_s + "'"
    return escolha
  end
  
  def GetGameLevel
    puts "Escolha Nivel do Jogo:\n  0-Fácil\n  1-Médio\n  2-Dificil\n"  
    puts "Enter [0-2]:"
    escolha = entre_com_uma_opcao(0,2)    
    if (escolha >= 0 && escolha < 3)
      return escolha
    end
    return 2
  end
  
  def start_game
    clean_board
    # Geting Game Type
    tipo_jogo = 0
    tipo_jogo = getGameType()
    @nivel_dificuldade = 2
    if (tipo_jogo == 0 || tipo_jogo == 1)
      #Caso haja CPU escolher o nível de dificuldade
      @nivel_dificuldade = GetGameLevel()
      puts "Você escolheu o nível '" + @Jogo_Level[@nivel_dificuldade].to_s + "'"
    end
    # start getting Level
    # start by printing the board
    puts "Vamos começar:\n\n"
    print_board
    if (tipo_jogo != 1) #Se só estão jogando computadores não precisa 
      puts "Enter [0-8]:"
    end
    # loop through until the game was won or tied
    vencedor = 0
    until game_is_over(@board) || tie(@board)
      vencedor = 1
      if (tipo_jogo != 1)
        get_human_spot(@hum)
      else
        eval_board(@hum)
      end
      if !game_is_over(@board) && !tie(@board)
        if (tipo_jogo != 2)
          eval_board(@com)
        else
          print_board_humanvshuman(tipo_jogo, 2)
          get_human_spot(@com)
        end
        vencedor = 2
      end
      if (tipo_jogo == 1) #Espaço entre tabuleiros caso seja CPUvsCPU
        puts "\n"
      end
      print_board_humanvshuman(tipo_jogo, 1)
    end    
    if (tie(@board))
      puts "Game over - Deu velha!"
    else
      puts "Game over - Player #{vencedor} Venceu!!" 
    end    
  end

  def get_human_spot(pstMarca)
    spot = nil
    until spot
      #spot = gets.chomp.to_i
      spot = entre_com_uma_opcao(0,8) 
      if @board[spot] != "X" && @board[spot] != "O"
        @board[spot] = pstMarca
      else
        puts "Este Local já foi escolhido anteriormente!"
        spot = nil
      end
    end
  end

  def getNetPlayer(pstMarca)
    #Pega a marcação oposta do jogador atual
    if (pstMarca == "O")
      return "X"
    else
      return "O"
    end    
  end
  
  def eval_board(pstMarca)
    spot = nil
    until spot
      if @board[4] == "4" && @nivel_dificuldade == 2 #facilitando dependendo do nivel de dificuldade     
        spot = 4
        @board[spot] = pstMarca
      else
        spot = get_best_move(@board, pstMarca, getNetPlayer(pstMarca))
        if @board[spot] != "X" && @board[spot] != "O"
          @board[spot] = pstMarca
        else
          spot = nil
        end
      end
    end
  end

  def get_best_move(board, pstMarca, next_player, depth = 0, best_score = {})
    available_spaces = []
    best_move = nil
    board.each do |s|
      if s != "X" && s != "O"
        available_spaces << s
      end
    end
    available_spaces.each do |as|
      board[as.to_i] = pstMarca
      if game_is_over(board)
        best_move = as.to_i
        board[as.to_i] = as
        #return best_move
      else
        board[as.to_i] = next_player
        if game_is_over(board)
          best_move = as.to_i
          board[as.to_i] = as
          #return best_move
        else
          board[as.to_i] = as
        end
      end
    end
    if best_move
      if (@nivel_dificuldade == 0) #Fácil!
        #Se nivel fácil retorne valor aleatorio disponível
        n = rand(0..available_spaces.count)
        return available_spaces[n].to_i
      else
        if (@nivel_dificuldade == 1) #Medio!
          puts "Testando a sorte" if DEBUG
          if (rand(0..100) > 50) #50% de receber um movimento fácil aleatório
            puts "sorte" if DEBUG
            n = rand(0..available_spaces.count)
            return available_spaces[n].to_i
          else
            puts "falta de sorte" if DEBUG
          end
        end
      end
      return best_move
    else
      n = rand(0..available_spaces.count)
      return available_spaces[n].to_i
    end
  end

  def game_is_over(b)
    [b[0], b[1], b[2]].uniq.length == 1 ||
    [b[3], b[4], b[5]].uniq.length == 1 ||
    [b[6], b[7], b[8]].uniq.length == 1 ||
    [b[0], b[3], b[6]].uniq.length == 1 ||
    [b[1], b[4], b[7]].uniq.length == 1 ||
    [b[2], b[5], b[8]].uniq.length == 1 ||
    [b[0], b[4], b[8]].uniq.length == 1 ||
    [b[2], b[4], b[6]].uniq.length == 1
  end

  def tie(b)
    b.all? { |s| s == "X" || s == "O" }
  end
  
end

game = Game.new
game.start_game
