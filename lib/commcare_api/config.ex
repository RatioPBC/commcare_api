defmodule CommcareAPI.Config do
  @moduledoc false

  @type t :: %__MODULE__{
          client: module(),
          http_client: module(),
          username: String.t(),
          user_id: String.t(),
          api_token: String.t()
        }

  @enforce_keys [:username, :user_id, :api_token]

  defstruct client: CommcareAPI.CommcareClient,
            http_client: HTTPoison,
            username: "must be provided",
            user_id: "must be provided",
            api_token: "must be provided"
end
