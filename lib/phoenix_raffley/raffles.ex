defmodule PhoenixRaffley.Raffle do
  defstruct [:id, :prize, :ticket_price, :status, :image_path, :description]
end

defmodule User do
  defstruct name: nil, age: nil
end

defmodule PhoenixRaffley.Raffles do

  def list_raffles() do
    [
      %PhoenixRaffley.Raffle{
        id: 1,
        prize: "Autographed Jersey",
        ticket_price: 2,
        status: :open,
        image_path: "/images/jersey.jpg",
        description: "Step up, sports fans!"
      },
      %PhoenixRaffley.Raffle{
        id: 2,
        prize: "Coffee with a Yeti",
        ticket_price: 3,
        status: :upcoming,
        image_path: "/images/yeti-coffee.jpg",
        description: "A super chill coffee date"
      },
      %PhoenixRaffley.Raffle{
        id: 3,
        prize: "Vintage comic book",
        ticket_price: 1,
        status: :closed,
        image_path: "/images/comic-book.jpg",
        description: "A rare collectible!"
      }
    ]
  end
end
