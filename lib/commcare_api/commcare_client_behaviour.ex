defmodule CommcareAPI.CommcareClientBehaviour do
  @moduledoc """
  Provides a mockable interface for the CommcareClient.
  """
  @callback get_case(commcare_domain :: String.t(), case_id :: String.t(), config :: CommcareAPI.Config.t()) :: {:ok, map()} | {:error, atom()}
end
