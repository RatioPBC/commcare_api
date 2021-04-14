defmodule CommcareAPI.FakeCommcare do
  @moduledoc """
  Statefully mocks the CommCare API.

  ## Usage

      iex> FakeCommcare.start_link("path/to/initial/state.json")
      iex> FakeCommcare.add_contact(body)
      iex> FakeCommcare.get_json()
  """
  use Agent

  @doc """
  Spins up the fake server by populating some initial based on the
  contents of the file.

  ## Example

      iex> start_link("path/to/state.json")
  """
  @spec start_link(String.t()) :: {:ok, pid()}
  def start_link(filename) do
    initial_state = filename |> File.read!() |> Jason.decode!()
    Agent.start_link(fn -> initial_state end, name: __MODULE__)
  end

  @doc """
  Returns the state of the server as JSON.

  ## Example

      iex> File.read!("path/to/state.json")
      "{\n  \"my\": \"state\"\n}"
      iex> CommcareAPI.FakeCommcare.start_link("path/to/state.json")
      {:ok, pid}
      iex> CommcareAPI.FakeCommcare.get_json()
      "{\"my\": \"state\"}"
  """
  @spec get_json :: binary
  def get_json do
    Agent.get(__MODULE__, & &1) |> Jason.encode!()
  end

  @doc """
  Adds a contact in XML form to the server state.

  ## Example

      iex> CommcareAPI.FakeCommcare.start_link("path/to/state.json")
      iex> xml = "<?xml version="1.0" ?>
        <data>
        ...
        </data>"
      iex> CommcareAPI.FakeCommcare.add_contact(xml)
      :ok
      iex> CommcareAPI.FakeCommcare.get_json()
      "{ json with the XML as contact }"
  """
  @spec add_contact(binary) :: :ok
  def add_contact(xml) do
    contact_map = xml |> xml_to_contact() |> to_map()

    Agent.update(__MODULE__, fn state ->
      child_cases = Map.get(state, "child_cases")
      updated_child_cases = Map.merge(child_cases, contact_map)
      Map.put(state, "child_cases", updated_child_cases)
    end)
  end

  @doc false
  def to_map(contact) do
    %{
      contact.case_id => %{
        "properties" => %{
          "full_name" => contact.full_name,
          "phone_home" => contact.phone_home,
          "commcare_email_address" => contact.commcare_email_address
        }
      }
    }
  end

  @doc false
  def xml_to_contact(xml) do
    parsed = Floki.parse_document!(xml)

    case_id = Floki.attribute(parsed, "data case", "case_id") |> List.first()
    full_name = Floki.find(parsed, "data case update full_name") |> Floki.text()
    phone_home = Floki.find(parsed, "data case update phone_home") |> Floki.text()
    commcare_email_address = Floki.find(parsed, "data case update commcare_email_address") |> Floki.text()

    %{full_name: full_name, case_id: case_id, phone_home: phone_home, commcare_email_address: commcare_email_address}
  end
end
