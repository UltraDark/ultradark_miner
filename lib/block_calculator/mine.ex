defmodule Miner.BlockCalculator.Mine do
  use Task
  alias Miner.BlockCalculator
  alias Elixium.Block
  alias Elixium.Store.Ledger
  alias Elixium.Transaction
  alias Decimal, as: D
  alias Elixium.Utilities
  require Logger

  def start(address, transactions) do
    Task.start(__MODULE__, :mine, [address, transactions])
  end

  def mine(address, transactions) do
    block =
      case Ledger.last_block() do
        :err -> Block.initialize()
        last_block -> Block.initialize(last_block)
      end

    block = Map.put(block, :transactions, transactions)

    Logger.info("Mining block at index #{:binary.decode_unsigned(block.index)}...")

    mined_block =
      block
      |> calculate_coinbase_amount
      |> Transaction.generate_coinbase(address)
      |> merge_block(block)
      |> Block.mine()

    Logger.info("Calculated hash for block at index #{:binary.decode_unsigned(block.index)}.")

    BlockCalculator.finished_mining(mined_block)
  end

  @spec calculate_coinbase_amount(Block) :: Decimal
  defp calculate_coinbase_amount(block) do
    index = :binary.decode_unsigned(block.index)
    D.add(Block.calculate_block_reward(index), Block.total_block_fees(block.transactions))
  end

  defp merge_block(coinbase, block) do
    transactions = [coinbase | block.transactions]
    txdigests = Enum.map(transactions, &:erlang.term_to_binary/1)

    Map.merge(block, %{
      transactions: transactions,
      merkle_root: Utilities.calculate_merkle_root(txdigests)
    })
  end
end
