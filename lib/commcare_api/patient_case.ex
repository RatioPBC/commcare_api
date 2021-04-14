defmodule CommcareAPI.PatientCase do
  @moduledoc """
  A struct that represents a patient in CommCare.
  """

  @derive Jason.Encoder

  @type t :: %__MODULE__{
          case_id: String.t(),
          child_cases: map(),
          city: String.t(),
          date_tested: Date.t() | nil,
          dob: Date.t() | nil,
          domain: String.t(),
          full_name: String.t(),
          first_name: String.t(),
          last_name: String.t(),
          owner_id: String.t(),
          phone_home: String.t(),
          state: String.t(),
          street: String.t(),
          zip_code: String.t()
        }

  defstruct case_id: nil,
            case_type: nil,
            child_cases: %{},
            city: nil,
            date_tested: nil,
            dob: nil,
            domain: nil,
            full_name: nil,
            first_name: nil,
            last_name: nil,
            owner_id: nil,
            phone_home: nil,
            state: nil,
            street: nil,
            zip_code: nil

  @spec new(patient_case_json :: map()) :: {:ok, t()} | {:error, binary()}
  def new(patient_case_json) do
    try do
      properties = patient_case_json["properties"]

      {:ok,
       %__MODULE__{
         case_id: patient_case_json["case_id"],
         case_type: properties["case_type"],
         city: properties["address_city"],
         child_cases: patient_case_json["child_cases"],
         date_tested: get_date_tested(patient_case_json),
         dob: get_dob(patient_case_json),
         domain: patient_case_json["domain"],
         full_name: properties["full_name"],
         first_name: properties["first_name"],
         last_name: properties["last_name"],
         owner_id: properties["owner_id"],
         phone_home: properties["phone_home"],
         state: properties["address_state"],
         street: properties["address_street"],
         zip_code: properties["address_zip"]
       }}
    rescue
      _error -> {:error, "error getting one of the values from the commcare data"}
    end
  end

  defp get_dob(patient_case_json) do
    patient_case_json |> get_in(["properties", "dob"]) |> parse_date()
  end

  defp get_date_tested(patient_case_json) do
    patient_case_json
    |> get_lab_result()
    |> get_date_tested_from_lab_result()
  end

  defp get_date_tested_from_lab_result(nil), do: nil

  defp get_date_tested_from_lab_result(lab_result) do
    lab_result |> get_in(["properties", "specimen_collection_date"]) |> parse_date()
  end

  defp get_lab_result(patient_case_json) do
    patient_case_json["child_cases"]
    |> Enum.find(fn {_child_case_id, child_case} -> child_case["properties"]["case_type"] == "lab_result" end)
    |> case do
      nil -> nil
      {_, lab_result} -> lab_result
    end
  end

  defp parse_date(nil), do: nil

  defp parse_date(date_string) do
    case Date.from_iso8601(date_string) do
      {:ok, date} -> date
      {:error, _} -> nil
    end
  end
end
