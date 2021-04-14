defmodule CommcareAPI.FakeCommcareTest do
  use ExUnit.Case, async: true

  alias CommcareAPI.{Factory, FakeCommcare}

  test "xml_to_contact() gets the pieces out from the XML post" do
    username = "username"
    user_id = "user_id"
    contact = Factory.build_contact(%{name: "Bob Jones", email: "bob@example.com", phone: "5035550123", case_id: "bbb-bbb"})
    commcare_data = %{owner_id: "owner_id", case_id: "ccc-ccc"}

    xml =
      CommcareAPI.AddContactXml.render(
        contact,
        commcare_data,
        Timex.now() |> Timex.format!("{ISO:Extended}"),
        username,
        user_id,
        "aaa-aaaa-aaaaa"
      )

    parsed_contact = FakeCommcare.xml_to_contact(xml)

    assert parsed_contact.case_id == "bbb-bbb"
    assert parsed_contact.full_name == "Bob Jones"
    assert parsed_contact.phone_home == "5035550123"
    assert parsed_contact.commcare_email_address == "bob@example.com"
  end

  test "to_map" do
    contact =
      Factory.build_contact(%{
        full_name: "Bob Jones",
        case_id: "bbb-bbb",
        phone_home: "5035550123",
        commcare_email_address: "bob@example.com"
      })

    map = FakeCommcare.to_map(contact)

    assert map == %{
             "bbb-bbb" => %{
               "properties" => %{
                 "full_name" => "Bob Jones",
                 "phone_home" => "5035550123",
                 "commcare_email_address" => "bob@example.com"
               }
             }
           }
  end
end
