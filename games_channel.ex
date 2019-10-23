defmodule MemoryWeb.GamesChannel do
  use MemoryWeb, :channel

  alias Memory.Game
  alias Memory.BackupAgent

  def join("games:" <> name, payload, socket) do
    if authorized?(payload) do
      game = BackupAgent.get(name) || Game.new()
      socket = socket
      |> assign(:game, game)
      |> assign(:name, name)
      BackupAgent.put(name, game)
      {:ok, %{"join" => name, "game" => Game.client_view(game)}, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("new", socket) do
    name = socket.assigns[:name]
    game = Game.new(socket.assigns[:game])
    socket = assign(socket, :game, game)
    BackupAgent.put(name, game)
    {:reply, {:ok, %{ "game" => Game.client_view(game)}}, socket}
  end

  def handle_in("dropFromRemaining", %{"player" => ll, "change" => mm}, socket) do
    name = socket.assigns[:name]                    
    game = Game.dropFromRemaining(socket.assigns[:game], ll, mm)                                                                                                                                                            
    socket = assign(socket, :game, game)
    BackupAgent.put(name, game)                                                                                                                                                                          
    {:reply, {:ok, %{ "game" => Game.client_view(game)}}, socket}
  end

  def handle_in("dropFromAside", %{"player" => ll, "change" => mm}, socket) do
    name = socket.assigns[:name]                    
    game = Game.dropFromAside(socket.assigns[:game], ll, mm)                                                                                                                                                            
    socket = assign(socket, :game, game)
    BackupAgent.put(name, game)                                                                                                                                                                          
    {:reply, {:ok, %{ "game" => Game.client_view(game)}}, socket}
  end

  def handle_in("dropToAside", %{"player" => ll}, socket) do
    name = socket.assigns[:name]                    
    game = Game.dropToAside(socket.assigns[:game], ll)                                                                                                                                                            
    socket = assign(socket, :game, game)
    BackupAgent.put(name, game)                                                                                                                                                                          
    {:reply, {:ok, %{ "game" => Game.client_view(game)}}, socket}
  end

  def handle_in("setLastChance", %{"player" => ll}, socket) do
    name = socket.assigns[:name]                    
    game = Game.setLastChance(socket.assigns[:game], ll)                                                                                                                                                            
    socket = assign(socket, :game, game)
    BackupAgent.put(name, game)                                                                                                                                                                          
    {:reply, {:ok, %{ "game" => Game.client_view(game)}}, socket}
  end

  def handle_in("refreshGame", %{"ref" => ll}, socket) do
    name = socket.assigns[:name]
    game = Game.refreshGame(socket.assigns[:game], ll)
    socket = assign(socket, :game, game)
    BackupAgent.put(name, game)
    {:reply, {:ok, %{ "game" => Game.client_view(game)}}, socket}
  end

  def handle_in("updateScore", %{"player" => ll}, socket) do
    name = socket.assigns[:name]                    
    game = Game.updateScore(socket.assigns[:game], ll)                                                                                                                                                            
    socket = assign(socket, :game, game)
    BackupAgent.put(name, game)                                                                                                                                                                          
    {:reply, {:ok, %{ "game" => Game.client_view(game)}}, socket}
  end

  
  ## Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
