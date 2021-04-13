defmodule CommcareAPI.AddContactXml do
  @moduledoc """
  See #render doc
  """

  @doc """
  Constructs an xml document that can be used to add a contact to a case in commcare
  """
  def render(contact, commcare_data, timestamp, username, user_id, instance_id) do
    """
    <?xml version="1.0" ?>
    <data xmlns="http://resolvetosavelives.org/ratio_pbc-share-my-contacts/post-contact">
        <n0:case case_id="#{contact.case_id}" xmlns:n0="http://commcarehq.org/case/transaction/v2">
            <n0:create>
                <n0:case_name>#{contact.name}</n0:case_name>
                <n0:case_type>contact</n0:case_type>
            </n0:create>
            <n0:update>
                <n0:commcare_email_address>#{contact.email}</n0:commcare_email_address>
                <n0:phone_home>#{contact.phone}</n0:phone_home>
                <n0:full_name>#{contact.name}</n0:full_name>
                #{first_name_tag(contact)}
                #{last_name_tag(contact)}
                #{contact_type_tag(contact)}
                #{relationship_tag(contact)}
                #{primary_language_tag(contact)}
                <n0:owner_id>#{commcare_data.owner_id}</n0:owner_id>
                <n0:contact_is_a_minor>#{contact_is_a_minor(contact)}</n0:contact_is_a_minor>
            </n0:update>
            <n0:index>
                <n0:parent case_type="patient">#{commcare_data.case_id}</n0:parent>
            </n0:index>
        </n0:case>
        <n1:case case_id="#{commcare_data.case_id}" xmlns:n1="http://commcarehq.org/case/transaction/v2">
            <n1:update/>
        </n1:case>
        <n2:meta xmlns:n2="http://openrosa.org/jr/xforms">
            <n2:timeStart>#{timestamp}</n2:timeStart>
            <n2:timeEnd>#{timestamp}</n2:timeEnd>
            <n2:username>#{username}</n2:username>
            <n2:userID>#{user_id}</n2:userID>
            <n2:instanceID>#{instance_id}</n2:instanceID>
        </n2:meta>
    </data>
    """
  end

  defp contact_type_tag(%{contact_type: contact_type}), do: "<n0:contact_type>#{contact_type}</n0:contact_type>"
  defp contact_type_tag(_), do: nil

  defp first_name_tag(%{first_name: first_name}), do: "<n0:first_name>#{first_name}</n0:first_name>"
  defp first_name_tag(_), do: nil

  defp last_name_tag(%{last_name: last_name}), do: "<n0:last_name>#{last_name}</n0:last_name>"
  defp last_name_tag(_), do: nil

  defp contact_is_a_minor(%{is_minor: true}), do: "yes"
  defp contact_is_a_minor(_), do: nil

  defp primary_language_tag(%{primary_language: primary_language}), do: "<n0:primary_language>#{primary_language}</n0:primary_language>"
  defp primary_language_tag(_), do: nil

  defp relationship_tag(%{relationship: relationship}), do: "<n0:relationship>#{relationship}</n0:relationship>"
  defp relationship_tag(_), do: nil
end
