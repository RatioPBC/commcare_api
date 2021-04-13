defmodule CommcareAPI.AddContactXmlTest do
  use ExUnit.Case, async: true

  alias CommcareAPI.AddContactXml
  alias CommcareAPI.Factory

  setup do
    commcare_data = %{owner_id: "owner_id", case_id: "ccc-ccc"}
    username = "username"
    user_id = "user_id"

    %{contact: Factory.build_contact(), commcare_data: commcare_data, username: username, user_id: user_id}
  end

  describe "render/6" do
    test "when is_minor is true returns contact_is_a_minor: yes", %{
      contact: contact,
      commcare_data: commcare_data,
      username: username,
      user_id: user_id
    } do
      xml = render_xml(%{contact | is_minor: true}, commcare_data, username, user_id)

      assert contact_is_a_minor?(xml)
    end

    test "when is_minor is false returns blank field for contact_is_a_minor",
         %{contact: contact, commcare_data: commcare_data, username: username, user_id: user_id} do
      xml = render_xml(%{contact | is_minor: false}, commcare_data, username, user_id)

      refute contact_is_a_minor?(xml)
    end

    test "returns first name tag", %{contact: contact, commcare_data: commcare_data, username: username, user_id: user_id} do
      first_name = "Randy"
      xml = render_xml(%{contact | first_name: first_name}, commcare_data, username, user_id)
      assert contact_name(xml, :first_name) == first_name
    end

    test "returns last name tag", %{contact: contact, commcare_data: commcare_data, username: username, user_id: user_id} do
      last_name = "Johnson"
      xml = render_xml(%{contact | last_name: last_name}, commcare_data, username, user_id)
      assert contact_name(xml, :last_name) == last_name
    end

    test "returns full name tag", %{contact: contact, commcare_data: commcare_data, username: username, user_id: user_id} do
      name = "Randy Johnson"
      xml = render_xml(%{contact | name: name}, commcare_data, username, user_id)
      assert contact_name(xml, :full_name) == name
    end

    test "returns contact location tag", %{contact: contact, commcare_data: commcare_data, username: username, user_id: user_id} do
      contact_type = "workplace"
      xml = render_xml(%{contact | contact_type: contact_type}, commcare_data, username, user_id)
      assert contact_name(xml, :contact_type) == contact_type
    end

    test "returns primary_language tag", %{contact: contact, commcare_data: commcare_data, username: username, user_id: user_id} do
      primary_language = "wakandan"
      xml = render_xml(%{contact | primary_language: primary_language}, commcare_data, username, user_id)
      assert contact_name(xml, :primary_language) == primary_language
    end

    test "returns relationship tag", %{contact: contact, commcare_data: commcare_data, username: username, user_id: user_id} do
      relationship = "neighbor"
      xml = render_xml(%{contact | relationship: relationship}, commcare_data, username, user_id)
      assert contact_name(xml, :relationship) == relationship
    end

    defp render_xml(contact, commcare_data, username, user_id) do
      AddContactXml.render(
        contact,
        commcare_data,
        Timex.now()
        |> Timex.format!("{ISO:Extended}"),
        username,
        user_id,
        "aaa-aaaa-aaaaa"
      )
    end

    defp contact_name(xml, name) do
      xml
      |> Floki.parse_document!()
      |> Floki.find("data case update #{name}")
      |> Floki.text()
    end

    defp contact_is_a_minor?(xml) do
      parsed_minor_field =
        xml
        |> Floki.parse_document!()
        |> Floki.find("data case update contact_is_a_minor")
        |> Floki.text()

      parsed_minor_field == "yes"
    end
  end
end
