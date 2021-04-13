defmodule CommcareAPI.CommcareClientBehaviour do
  @callback get_case(commcare_domain :: String.t(), case_id :: String.t(), config :: CommcareAPI.Config.t()) :: {:ok, map()} | {:error, atom()}
end
