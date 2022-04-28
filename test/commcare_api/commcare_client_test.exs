defmodule CommcareAPI.CommcareClientTest do
  use ExUnit.Case, async: false
  import Mox

  alias CommcareAPI.{CommcareClient, HTTPoisonMock, PatientCase}

  setup :set_mox_global
  setup :verify_on_exit!

  setup do
    [commcare_api_config: %CommcareAPI.Config{http_client: HTTPoisonMock, username: "ratio_pbc_user_1", user_id: "abc123", api_token: "asdf"}]
  end

  describe "get_case" do
    test "returns an error when no case is found for this case id is found", %{commcare_api_config: commcare_api_config} do
      expect(HTTPoisonMock, :get, fn _url, _headers ->
        {:ok, %HTTPoison.Response{status_code: 404, body: ""}}
      end)

      assert CommcareClient.get_case("ratio_pbc", "non-existent-case", commcare_api_config) == {:error, :not_found}
    end

    test "returns an error when commcare authorization fails", %{commcare_api_config: commcare_api_config} do
      expect(HTTPoisonMock, :get, fn _url, _headers ->
        {:ok, %HTTPoison.Response{status_code: 401}}
      end)

      assert CommcareClient.get_case("ratio_pbc", "a-valid-case-id", commcare_api_config) == {:error, :commcare_authorization_error}
    end

    test "returns an error when we get a 403 back from CommcareClient", %{commcare_api_config: commcare_api_config} do
      expect(HTTPoisonMock, :get, fn _url, _headers ->
        Code.eval_file("test/fixtures/commcare/auth_error.exs") |> elem(0)
      end)

      assert CommcareClient.get_case("ratio_pbc", "some-auth-error", commcare_api_config) == {:error, :commcare_forbidden}
    end

    test "returns the JSON data when a case can be successfully looked up", %{commcare_api_config: commcare_api_config} do
      expect(HTTPoisonMock, :get, fn url, _headers ->
        assert url ==
                 "https://www.commcarehq.org/a/ratio_pbc/api/v0.5/case/00000000-0123-3210-5555-444444444444/?format=json&child_cases__full=true"

        json_string = File.read!("test/fixtures/commcare/00000000-0123-3210-5555-444444444444.json")
        {:ok, %HTTPoison.Response{status_code: 200, body: json_string}}
      end)

      {:ok, case} = CommcareClient.get_case("ratio_pbc", "00000000-0123-3210-5555-444444444444", commcare_api_config)

      assert case["case_id"] == "00000000-0123-3210-5555-444444444444"
      assert case["properties"]["owner_id"] == "00000000706549328e8407ca1388c138"
    end

    test "uses Bearer token auth", %{commcare_api_config: commcare_api_config} do
      expect(HTTPoisonMock, :get, fn _url, _headers ->
        json_string = File.read!("test/fixtures/commcare/00000000-0123-3210-5555-444444444444.json")
        {:ok, %HTTPoison.Response{status_code: 200, body: json_string}}
      end)

      CommcareClient.get_case("ratio_pbc", "00000000-0123-3210-5555-444444444444", commcare_api_config)
    end
  end

  describe "get_user" do
    test "returns an error when no user is found for this user id is found", %{commcare_api_config: commcare_api_config} do
      expect(HTTPoisonMock, :get, fn _url, _headers ->
        {:ok, %HTTPoison.Response{status_code: 404, body: ""}}
      end)

      assert CommcareClient.get_user("ratio_pbc", "non-existent-user", commcare_api_config) == {:error, :not_found}
    end

    test "returns an error when commcare authorization fails", %{commcare_api_config: commcare_api_config} do
      expect(HTTPoisonMock, :get, fn _url, _headers ->
        {:ok, %HTTPoison.Response{status_code: 401}}
      end)

      assert CommcareClient.get_user("ratio_pbc", "a-valid-user-id", commcare_api_config) == {:error, :commcare_authorization_error}
    end

    test "returns an error when we get a 403 back from CommcareClient", %{commcare_api_config: commcare_api_config} do
      expect(HTTPoisonMock, :get, fn _url, _headers ->
        Code.eval_file("test/fixtures/commcare/auth_error.exs") |> elem(0)
      end)

      assert CommcareClient.get_user("ratio_pbc", "some-auth-error", commcare_api_config) == {:error, :commcare_forbidden}
    end

    test "returns the JSON data when a case can be successfully looked up", %{commcare_api_config: commcare_api_config} do
      expect(HTTPoisonMock, :get, fn url, _headers ->
        assert url == "https://www.commcarehq.org/a/ratio_pbc/api/v0.5/user/111222333444555/?format=json"
        json_string = File.read!("test/fixtures/commcare/111222333444555.json")
        {:ok, %HTTPoison.Response{status_code: 200, body: json_string}}
      end)

      {:ok, user} = CommcareClient.get_user("ratio_pbc", "111222333444555", commcare_api_config)

      assert user["id"] == "111222333444555"
      assert user["email"] == "ci_1@example.com"
    end

    test "uses Bearer token auth", %{commcare_api_config: commcare_api_config} do
      expect(HTTPoisonMock, :get, fn _url, _headers ->
        json_string = File.read!("test/fixtures/commcare/111222333444555.json")
        {:ok, %HTTPoison.Response{status_code: 200, body: json_string}}
      end)

      CommcareClient.get_user("ratio_pbc", "111222333444555", commcare_api_config)
    end

    test "returns an error if the user does not exist in CommCare", %{commcare_api_config: commcare_api_config} do
      expect(HTTPoisonMock, :get, fn _url, _headers ->
        json_string = """
                {
                    "error": "The object 'CommCareUser(username=None)' has an empty attribute 'get_id' and doesn't allow a default or null value."
                }
        """

        {:ok, %HTTPoison.Response{status_code: 400, body: json_string}}
      end)

      assert CommcareClient.get_user("ratio_pbc", "user-does-not-exist", commcare_api_config) == {:error, :commcare_data_error}
    end
  end

  describe "ping" do
    test "success returns :ok", %{commcare_api_config: commcare_api_config} do
      expect(HTTPoisonMock, :get, fn "https://www.commcarehq.org/accounts/login/" ->
        {:ok, %HTTPoison.Response{status_code: 200, body: ""}}
      end)

      assert :ok = CommcareClient.ping(commcare_api_config)
    end

    test "returns error on non-200", %{commcare_api_config: commcare_api_config} do
      expect(HTTPoisonMock, :get, fn "https://www.commcarehq.org/accounts/login/" ->
        {:ok, %HTTPoison.Response{status_code: 404, body: ""}}
      end)

      assert {:error, %HTTPoison.Response{status_code: 404, body: ""}} = CommcareClient.ping(commcare_api_config)
    end

    test "returns error response", %{commcare_api_config: commcare_api_config} do
      expect(HTTPoisonMock, :get, fn "https://www.commcarehq.org/accounts/login/" ->
        {:error, :error_message}
      end)

      assert {:error, :error_message} = CommcareClient.ping(commcare_api_config)
    end
  end

  describe "post_contact" do
    setup do
      commcare_data = %PatientCase{
        case_id: "00000000-8434-4475-b111-bb3a902b398b",
        date_tested: ~D[2020-05-13],
        dob: ~D[1987-05-06],
        domain: "ratio_pbc",
        full_name: "Test JME3",
        owner_id: "000000009299465ab175357b95b89e7c",
        phone_home: "5035550100"
      }

      contact = %{
        name: "Bob DaBuilder",
        phone: "123456",
        email: "bob@example.com",
        case_id: "i-am-a-contact-case-uuid-stub"
      }

      success_response = File.read!("test/fixtures/commcare/post-response_success.xml")

      [commcare_data: commcare_data, contact: contact, success_response: success_response]
    end

    test "it posts to commcare", %{
      commcare_data: commcare_data,
      contact: contact,
      success_response: success_response,
      commcare_api_config: commcare_api_config
    } do
      timestamp_regex = ~r/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{6}\+(\d|:)*/
      id_regex = ~r/[0-9a-zA-Z\/+]{32}/

      expect(HTTPoisonMock, :post, fn url, body, _headers ->
        assert url == "https://www.commcarehq.org/a/ratio_pbc/receiver/"
        assert body =~ "<data xmlns=\"http://resolvetosavelives.org/ratio_pbc-share-my-contacts/post-contact\">"
        assert body =~ "<n0:case case_id=\"i-am-a-contact-case-uuid-stub\""
        assert body =~ "<n0:case_name>Bob DaBuilder</n0:case_name>"
        assert body =~ "<n0:commcare_email_address>bob@example.com</n0:commcare_email_address>"
        assert body =~ "<n0:phone_home>123456</n0:phone_home>"
        assert body =~ "<n0:full_name>Bob DaBuilder</n0:full_name>"
        assert body =~ "<n0:owner_id>000000009299465ab175357b95b89e7c</n0:owner_id>"
        assert body =~ "<n0:parent case_type=\"patient\">00000000-8434-4475-b111-bb3a902b398b</n0:parent>"
        assert body =~ "<n1:case case_id=\"00000000-8434-4475-b111-bb3a902b398b\""
        assert body =~ "<n2:meta xmlns:n2=\"http://openrosa.org/jr/xforms\">"
        assert Regex.match?(~r/<n2:timeStart>#{Regex.source(timestamp_regex)}<\/n2:timeStart>/, body)
        assert Regex.match?(~r/<n2:timeEnd>#{Regex.source(timestamp_regex)}<\/n2:timeEnd>/, body)
        assert body =~ "<n2:username>ratio_pbc_user_1</n2:username>"
        assert body =~ "<n2:userID>abc123</n2:userID>"
        assert Regex.match?(~r/<n2:instanceID>#{Regex.source(id_regex)}<\/n2:instanceID/, body)

        {:ok, %HTTPoison.Response{status_code: 201, body: success_response}}
      end)

      assert {:ok, _} = CommcareClient.post_contact(commcare_data, contact, commcare_api_config)
    end
  end
end
