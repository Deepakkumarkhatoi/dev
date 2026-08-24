import Ecto.Query

alias Payx.Repo
alias Payx.Schemas.Merchant

merchant = Repo.one!(from m in Merchant, limit: 1)

merchant
|> Ecto.Changeset.change(api_key: "xyz1")
|> Repo.update!()

IO.puts("Merchant API key updated to xyz1")