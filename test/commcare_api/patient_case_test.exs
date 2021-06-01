defmodule CommcareAPI.PatientCaseTest do
  use ExUnit.Case, async: true
  alias CommcareAPI.PatientCase

  describe "new/1" do
    test "it returns what questionnaire needs" do
      patient_case_json = File.read!("test/fixtures/commcare/case-with-test-results-and-contacts.json") |> Jason.decode!()
      {:ok, patient_case} = PatientCase.new(patient_case_json)

      assert patient_case.case_id == "00000000-8434-4475-b111-bb3a902b398b"
      assert patient_case.date_tested == ~D[2020-05-13]
      assert patient_case.dob == ~D[1987-05-05]
      assert patient_case.domain == "ratio_pbc"
      assert patient_case.full_name == "Test JME3"
      assert patient_case.owner_id == "000000009299465ab175357b95b89e7c"
      assert patient_case.phone_home == "5035550100"

      assert match?(
               %{
                 "00000000-c0f6-45bf-94a0-b858f59b48a7" => %{"case_id" => "00000000-c0f6-45bf-94a0-b858f59b48a7"},
                 "00000000-be32-49fc-ad5b-c6898afcf8aa" => %{"case_id" => "00000000-be32-49fc-ad5b-c6898afcf8aa"}
               },
               patient_case.child_cases
             )
    end

    test "it return what search needs" do
      patient_case_json = File.read!("test/fixtures/commcare/case-with-test-results-and-contacts.json") |> Jason.decode!()
      {:ok, patient_case} = PatientCase.new(patient_case_json)

      assert patient_case.case_id == "00000000-8434-4475-b111-bb3a902b398b"
      assert patient_case.dob == ~D[1987-05-05]
      assert patient_case.domain == "ratio_pbc"
      assert patient_case.first_name == "Test"
      assert patient_case.last_name == "JME3"
      assert patient_case.owner_id == "000000009299465ab175357b95b89e7c"
      assert patient_case.phone_home == "5035550100"
      assert patient_case.street == "123 Main St"
      assert patient_case.city == "Test"
      assert patient_case.state == "NY"
      assert patient_case.zip_code == "90210"
      assert patient_case.case_type == "patient"
    end

    test "it return interviewee parent name info" do
      patient_case_json = File.read!("test/fixtures/commcare/contact-with-interviewee-parent-name.json") |> Jason.decode!()
      {:ok, patient_case} = PatientCase.new(patient_case_json)

      assert patient_case.case_id == "00000000-eb0f-454c-ae1b-6da8ef431cfc"
      assert patient_case.domain == "ratio_pbc"
      assert patient_case.first_name == "Test"
      assert patient_case.last_name == "ParentGuardianTest"
      assert patient_case.case_type == "contact"
      assert patient_case.interviewee_parent_name == "Test ParentGuardianTest"
    end
  end

  describe "new/1, for bad lab_results," do
    test "returns nil for date_tested when specimen_collection_date is not present in the lab_result child case in the JSON" do
      patient_case_json = File.read!("test/fixtures/commcare/case-without-date-tested.json") |> Jason.decode!()
      {:ok, patient_case} = PatientCase.new(patient_case_json)
      assert patient_case.date_tested == nil
    end

    test "returns nil for date_tested when there is no lab result child case in the JSON" do
      patient_case_json = File.read!("test/fixtures/commcare/case-without-lab-result.json") |> Jason.decode!()
      {:ok, patient_case} = PatientCase.new(patient_case_json)
      assert patient_case.date_tested == nil
    end
  end

  describe "new/1, for bad dob," do
    test "returns nil for dob when dob is not present in the JSON" do
      patient_case_json = File.read!("test/fixtures/commcare/case-with-blank-dob.json") |> Jason.decode!()
      {:ok, patient_case} = PatientCase.new(patient_case_json)
      assert patient_case.dob == nil
    end

    test "returns nil for dob when dob is an empty string in the JSON" do
      patient_case_json = File.read!("test/fixtures/commcare/case-with-blank-dob.json") |> Jason.decode!()
      {:ok, patient_case} = PatientCase.new(patient_case_json)
      assert patient_case.dob == nil
    end

    test "returns nil for the dob when the field doesn't exist in the JSON" do
      patient_case_json = File.read!("test/fixtures/commcare/case-without-dob-field.json") |> Jason.decode!()
      {:ok, patient_case} = PatientCase.new(patient_case_json)
      assert patient_case.dob == nil
    end
  end
end
