defmodule CommcareAPI.FakeCommcare do
  use Agent

  def start_link(filename) do
    initial_state = File.read!(filename) |> Jason.decode!()
    Agent.start_link(fn -> initial_state end, name: __MODULE__)
  end

  def get_json() do
    Agent.get(__MODULE__, & &1) |> Jason.encode!()
  end

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
