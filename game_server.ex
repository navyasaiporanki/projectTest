defmodule Memory.GameServer do
    use GenServer

    def reg(name) do
        {:via, Registry, {Memory.GameReg, name}}
    end

    def start(name) do
        spec = %{
          id: __MODULE__,
          start: {__MODULE__, :start_link, [name]},
          restart: :permanent,
          type: :worker,
        }
        Memory.GameSup.start_child(spec)
    end
    def start_link(name) do
        game = Memory.BackupAgent.get(name) || Memory.Game.new()
        GenServer.start_link(__MODULE__, game, name: reg(name))
      end
    
    ## method for the dropFromRemaining 
      def dropFromRemaining(name, player, change) do 
        GenServer.call(reg(name), {:dropFromRemaining, player, change})
      end  

    ## method for the dropToAside
       def dropToAside(name, player) do 
         GenServer.call(reg(name), {:dropToAside,player})
       end

    ## method for the dropFromAside(game, player, change)
    
       def dropFromAside(name, player, change) do
           GenServer.call(reg(name), {:dropFromAside, player, change})
       end
      

    
      def peek(name) do
        GenServer.call(reg(name), {:peek, name})
      end
    
      def init(game) do
        IO.inspect("inside game server")
        IO.inspect(game)
        {:ok, game}
      end
    
    ## handle call for dropFromRemaining
      def handle_call({:dropFromRemaining, player, change}, _from, game) do 
        game =  Memory.Game.dropFromRemaining(game, player, change)
        #Memory.BackupAgent.put(name, game)
        {:reply, game, game}
      end

    ## handle call for dropToAside
      def handle_call({:dropToAside,player}, _from, game) do
        game = Memory.Game.dropToAside(game, player)
        #Memory.BackupAgent.put(name, game)
        {:reply, game, game}
       end 
       
      ## handle call for dropFromAside
      def handle_call({:dropFromAside, player, change}, _from, game) do
        game = Memory.Game.dropFromAside(game, player,change)
        #Memory.BackupAgent.put(name, game)
        {:reply, game, game}
      end 

    
      def handle_call({:peek, _name}, _from, game) do
        {:reply, game, game}
    end
end