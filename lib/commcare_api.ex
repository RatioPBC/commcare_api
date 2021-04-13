defmodule CommcareAPI do
  @moduledoc """
  Provides a CommCare API client for accessing patients.
  """
  alias CommcareAPI.{Config, PatientCase, PatientCaseProvider}

  require Logger

  @behaviour PatientCaseProvider

  @type query() :: %{domain: String.t(), case_id: String.t()}

  @impl CommcareAPI.PatientCaseProvider
  @spec get_patient_case(query :: query(), config :: Config.t()) ::
          {:ok, PatientCase.t()} | {:error, String.t() | atom()}
  def get_patient_case(%{domain: domain, case_id: case_id}, config) do
    with {:ok, patient_case_json} <- config.client.get_case(domain, case_id, config),
         {:ok, patient_case} <- PatientCase.new(patient_case_json) do
      # I don't think the stuff we log is mandated by anyone. Can probably simplify
      Logger.info("Successfully retrieved data from CommCare for case_id: '#{case_id}' and CommCare domain: '#{domain}'")
      {:ok, patient_case}
    else
      {:error, message} ->
        log_error(message, domain, case_id)
        {:error, message}
    end
  end

  defp log_error(message, domain, case_id) do
    case message do
      %{status_code: _} ->
        Logger.error("No case found in Commcare for case ID '#{case_id}' and domain #{domain}. Error: #{message}")

      _ ->
        Logger.error("Error: #{message}")
    end
  end
end
