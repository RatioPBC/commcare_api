defmodule CommcareAPI.Factory do
  @moduledoc "Builds fake data for various data models"

  def build_contact(overridden_attrs \\ %{}) do
    default = %{
      first_name: "Bob",
      last_name: "Jones",
      name: "Bob Jones",
      email: "bob@jones.com",
      phone: "5035550123",
      case_id: "bbb-bbb",
      is_minor: false,
      contact_type: nil,
      relationship: nil,
      primary_language: nil
    }

    Map.merge(default, overridden_attrs)
  end
end
