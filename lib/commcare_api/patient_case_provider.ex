defmodule CommcareAPI.PatientCaseProvider do
  @moduledoc """
  Provides a mockable behaviour for accessing patient cases from Commcare's Api
  """

  @type success :: {:ok, CommcareAPI.PatientCase.t()}
  @type error :: {:error, String.t() | atom()}
  @callback get_patient_case(any(), any()) :: success() | error()
end
