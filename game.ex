defmodule Memory.Game do

	def new() do
		%{
	      	allCards: [],
			cardNum: [],  
	      	asideCards: [],
	      	remainingCards: [],
			playerOneAssigned: [],
			playerTwoAssigned: [],
			playerOneCards: [],
			playerTwoCards: [],
			asidePile: [],
			remainingPile: [], 
			playerChance: 1,
			lastChance: false,
			scores: [["-","-"], ["-","-"], ["-","-"]],
			totalScore: ["-", "-"],
			currentRound: 1,
		}
		|> generateDeck()
		|> generateCardNum()
		|> assignCardsToPlayer(1)
		|> assignCardsToPlayer(2)
		|> assignAsidePile()
		|> assignRemainingCards()
		|> assignInitialPlayer1()
		|> assignInitialPlayer2()
		|> assignFirstRemaining()
		|> assignLastChance()
	end
	
	def client_view(game) do
	      ws = game.allCards
    		%{
				playerOneCards: game.playerOneCards,
				playerTwoCards: game.playerTwoCards,
				asidePile: game.asidePile,
				remainingPile: game.remainingPile,
				playerChance: game.playerChance,
				lastChance: game.lastChance,
				scores: game.scores,
				totalScore: game.totalScore
    		}
	end

	def generateDeck(game) do
		allValue = ["A", "J", "Q", "K", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
		allType = ["heart", "spade", "club", "diamond"]
		allCards = []
		allCards = fillCards(game, allValue, allType, allCards)
	end

	def fillCards(game, allValue, allType, allCards) when length(allValue) != 0 do
		value = Enum.at(allValue, 0)
		entry = []
		allCards = List.insert_at(allCards, length(allCards), [value, Enum.at(allType, 0)]) |>
				   List.insert_at(length(allCards), [value, Enum.at(allType, 1)]) |>
				   List.insert_at(length(allCards), [value, Enum.at(allType, 2)]) |>
				   List.insert_at(length(allCards), [value, Enum.at(allType, 3)])	
		allValue = allValue -- [value]
		fillCards(game, allValue, allType, allCards)
	end

	def fillCards(game, allValue, allType, allCards) when length(allValue) == 0 do
		Map.put(game, :allCards, allCards)
	end

	def generateCardNum(game) do
		nums = 0..51
		cardNum = Enum.to_list(nums)
		Map.put(game, :cardNum, cardNum)
	end

	def assignCardsToPlayer(game, player) do
		nums = game.cardNum
		cards = game.allCards
		playerCards = []
		assignCardsHelper(player, game, playerCards, nums, cards, 1)	
	end

	def assignCardsHelper(player, game, playerCards, nums, cards, index) when index <= 6 do
		randNum = Enum.random(nums)
		nums = nums -- [randNum]
		playerCards = List.insert_at(playerCards, index - 1, Enum.at(cards, randNum))
		assignCardsHelper(player, game, playerCards, nums, cards, index+1)
	end

	def assignCardsHelper(player, game, playerCards, nums, cards, index) when index > 6 do
		if player == 1 do
			game = game |> Map.put(:cardNum, nums) |> Map.put(:playerOneAssigned, playerCards)
		else	
			game = game |> Map.put(:cardNum, nums) |> Map.put(:playerTwoAssigned, playerCards)
		end
	end

	def assignAsidePile(game) do
		Map.put(game, :asidePile, [["empty", "empty"]])
	end

	def assignRemainingCards(game) do
		nums =  game.cardNum
		cards = game.allCards
		remainingCards = []
		assignRemainingCardsHelper(game, remainingCards, nums ,cards)
	  
	end

	def assignRemainingCardsHelper(game, remainingCards, nums ,cards)  when length(nums) > 0 do
		randNum =  Enum.random(nums)
		nums = nums -- [randNum]
		remainingCards = List.insert_at(remainingCards, length(remainingCards), Enum.at(cards, randNum))
		assignRemainingCardsHelper(game, remainingCards, nums ,cards) 		
	end

	def assignRemainingCardsHelper(game, remainingCards, nums ,cards)  when length(nums) == 0 do
		game = game |> Map.put(:remainingCards, remainingCards) |> Map.put(:cardNum, nums)
	end

	def assignFirstRemaining(game) do
		localRemain = []
		localRemain =  Enum.at(game.remainingCards, 0)
		Map.put(game, :remainingPile, localRemain)
	end

	def assignInitialPlayer1(game) do
		playerOneAssigned = game.playerOneAssigned
		tempList = []
		tempList = List.duplicate([" ", " "], 6)
		tempList = List.replace_at(tempList, 1, Enum.at(playerOneAssigned, 1))
		tempList = List.replace_at(tempList, 4, Enum.at(playerOneAssigned, 4))
		Map.put(game, :playerOneCards, tempList)
	end

	def assignInitialPlayer2(game) do
		playerTwoAssigned = game.playerTwoAssigned
		tempList = []
		tempList = List.duplicate([" ", " "], 6)
		tempList = List.replace_at(tempList, 1, Enum.at(playerTwoAssigned, 1))
		tempList = List.replace_at(tempList, 4, Enum.at(playerTwoAssigned, 4))
		Map.put(game, :playerTwoCards, tempList)
	end

	def assignLastChance(game) do
		Map.put(game, :lastChance, false)
	end

	def dropFromRemaining(game, player, change) do
		remainingCards = game.remainingCards
		asidePile = game.asidePile

		remainingPile = game.remainingPile
		remainingCards = remainingCards -- [remainingPile]
		
		asignToPlayer = remainingPile
		whichPlayer = []
		if player == 1 do
			playerChance =  game.playerChance
			playerChance = 2
			whichPlayer = game.playerOneAssigned
			asidePile = asidePile ++ [Enum.at(whichPlayer, change - 1)]
			whichPlayer = List.replace_at(whichPlayer, change - 1 , asignToPlayer)
			remainingPile = Enum.at(remainingCards, 0)
			playerOneCards = game.playerOneCards
			playerOneCards = List.replace_at(playerOneCards, change - 1, Enum.at(whichPlayer, change - 1))
			game = game |> Map.put(:remainingCards, remainingCards) |> Map.put(:asidePile, asidePile) |> Map.put(:remainingPile, remainingPile) 
						|> Map.put(:playerOneAssigned, whichPlayer) |> Map.put(:playerOneCards, playerOneCards) |> Map.put(:playerChance, playerChance)
		else
			playerChance =  game.playerChance
			playerChance = 1
			whichPlayer = game.playerTwoAssigned
			asidePile = asidePile ++ [Enum.at(whichPlayer, change - 1)]
			whichPlayer = List.replace_at(whichPlayer, change - 1 , asignToPlayer)
			remainingPile = Enum.at(remainingCards, 0)
			playerTwoCards = game.playerTwoCards
			playerTwoCards = List.replace_at(playerTwoCards, change - 1, Enum.at(whichPlayer, change - 1))
			game = game |> Map.put(:remainingCards, remainingCards) |> Map.put(:asidePile, asidePile) |> Map.put(:remainingPile, remainingPile) 
						|> Map.put(:playerTwoAssigned, whichPlayer)  |> Map.put(:playerTwoCards, playerTwoCards) |> Map.put(:playerChance, playerChance)
		end
		
	end

	def dropToAside(game, player) do
		playerChance = game.playerChance
		remainingCards = game.remainingCards
		asidePile = game.asidePile
		remainingPile = game.remainingPile
		asidePile = asidePile ++ [remainingPile]
		remainingCards = remainingCards -- [remainingPile]
		remainingPile = Enum.at(remainingCards, 0)
		if playerChance ==  1 do
			game = game |> Map.put(:remainingCards, remainingCards) |> Map.put(:asidePile, asidePile) |> Map.put(:remainingPile, remainingPile) |> Map.put(:playerChance, 2)
		else
			game = game |> Map.put(:remainingCards, remainingCards) |> Map.put(:asidePile, asidePile) |> Map.put(:remainingPile, remainingPile) |> Map.put(:playerChance, 1)
		end		
	end

	def dropFromAside(game, player, change) do
		asidePile = game.asidePile
		whichPlayer = []
		if player == 1 do
			playerChance =  game.playerChance
			playerChance = 2
			whichPlayer = game.playerOneAssigned
			playerOneCards = game.playerOneCards
			asidePile = asidePile ++ [Enum.at(whichPlayer, change - 1)]
			whichPlayer = List.replace_at(whichPlayer, change - 1, Enum.at(asidePile, length(asidePile) - 2))
			asidePile = asidePile -- [Enum.at(asidePile, length(asidePile) - 2)]
			playerOneCards = List.replace_at(playerOneCards, change - 1, Enum.at(whichPlayer, change - 1))
			game = game |> Map.put(:playerOneAssigned, whichPlayer) |> Map.put(:playerOneCards, playerOneCards) |> Map.put(:asidePile, asidePile) |> Map.put(:playerChance, playerChance)
		else
			playerChance =  game.playerChance
			playerChance = 1		
			whichPlayer = game.playerTwoAssigned
			playerTwoCards = game.playerTwoCards
			asidePile = asidePile ++ [Enum.at(whichPlayer, change - 1)]
			whichPlayer = List.replace_at(whichPlayer, change - 1, Enum.at(asidePile, length(asidePile) - 2))
			asidePile = asidePile -- [Enum.at(asidePile, length(asidePile) - 2)]
			playerTwoCards = List.replace_at(playerTwoCards, change - 1, Enum.at(whichPlayer, change - 1))
			game = game |> Map.put(:playerTwoAssigned, whichPlayer) |> Map.put(:playerTwoCards, playerTwoCards) |> Map.put(:asidePile, asidePile) |> Map.put(:playerChance, playerChance)
		end
	end

	def setLastChance(game, player) do
		Map.put(game, :lastChance, true)
	end

	## A method calling from react after the game completes.
	def updateScore(game, player) do
		
		player1Cards = game.playerOneAssigned
		player1_score = scoreMechanism(player1Cards)

		player2Cards = game.playerTwoAssigned
		player2_score = scoreMechanism(player2Cards)

	
		scores_game = [player1_score] ++ [player2_score]

		round = game.currentRound
		scores = game.scores
		scores = List.insert_at(scores, round - 1, scores_game)

		game = game
		|> generateDeck()
		|> generateCardNum()
		|> assignCardsToPlayer(1)
		|> assignCardsToPlayer(2)
		|> assignAsidePile()
		|> assignRemainingCards()
		|> assignInitialPlayer1()
		|> assignInitialPlayer2()
		|> assignFirstRemaining()
		|> increaseGameRound()

		if round ==  1 do
			game = game |> Map.put(:scores, scores) |> Map.put(:totalScore, scores_game)
		else
			totalScorePlayers = game.totalScore
			playerOneTotalScore = Enum.at(totalScorePlayers, 0)
			playerTwoTotalScore = Enum.at(totalScorePlayers, 1)

			IO.inspect("player one score")
			IO.inspect(playerOneTotalScore)

			IO.inspect("player two score")
			IO.inspect(scores_game)
			playerOneRoundScore = Enum.at(scores_game, 0)
			playerTwoRoundScore = Enum.at(scores_game, 1)

			playerOneTotalScore = playerOneTotalScore + playerOneRoundScore
			playerTwoTotalScore = playerTwoTotalScore + playerTwoRoundScore
			totalScore = [playerOneTotalScore] ++ [playerTwoTotalScore]

			game = game |> Map.put(:scores, scores) |> Map.put(:totalScore, totalScore)
		end

	end

	
	## increement to the next round
	def increaseGameRound(game) do
		round = game.currentRound
		round = round + 1
		Map.put(game, :currentRound, round)
	end


	## Method to calculate scores. we pass a list to it.
	def scoreMechanism(localList) do
		#localList = [["2", "heart"], ["3", "heart"], ["4", "heart"], ["A", "heart"], ["J", "heart"], ["K", "heart"]]
		getScore  = scoreMechanismForSame(localList, 0, 0)
	end

	## Helper method for the calculating score
	def scoreMechanismForSame(incomingList, score, index) when index < 3 do
		scoreMap = %{"K" => 0, "A" => 1, "J" => 10, "Q" => 10, "2" => 2, "3" => 3, "4" => 4, "5" => 5, "6" => 6, "7" => 7, "8" => 8, "9" => 9, "10" => 10}
		firstValue = Enum.at(incomingList, index)
		getFirstValue = Enum.at(firstValue, 0)

		localIndex = index + 3
		secondValue = Enum.at(incomingList, localIndex)
		getSecondValue = Enum.at(secondValue, 0)

		if getFirstValue == getSecondValue do
			scoreMechanismForSame(incomingList, score, index + 1)
		else
			scoreNew = score + Map.fetch!(scoreMap, getFirstValue) + Map.fetch!(scoreMap, getSecondValue) 
			scoreMechanismForSame(incomingList, scoreNew, index + 1)
		end


	end

	## returning the score which we calculated
	def scoreMechanismForSame(inputList, score, index) when index >= 3 do
		score
	end


end
