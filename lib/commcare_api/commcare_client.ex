defmodule CommcareAPI.CommcareClient do
  @behaviour CommcareAPI.CommcareClientBehaviour

  alias CommcareAPI.Config
  alias Euclid.Extra.Random

  @impl CommcareAPI.CommcareClientBehaviour
  @spec get_case(commcare_domain :: String.t(), case_id :: String.t(), config :: Config.t()) :: {:ok, map()} | {:error, atom()}
  def get_case(commcare_domain, case_id, config) do
    commcare_api_case_url(commcare_domain, case_id)
    |> config.http_client.get(headers(config))
    |> parse_response()
  end

  def get_user(commcare_domain, user_id, config) do
    commcare_api_user_url(commcare_domain, user_id)
    |> config.http_client.get(headers(config))
    |> parse_response()
  end

  @spec post_contact(commcare_data :: map(), contact :: map(), config :: Config.t()) :: {:ok, term()} | {:error, term()}
  def post_contact(commcare_data, contact, config) do
    url = "https://www.commcarehq.org/a/#{commcare_data.domain}/receiver/"
    username = config.username
    user_id = config.user_id

    body =
      CommcareAPI.AddContactXml.render(
        contact,
        commcare_data,
        Timex.now() |> Timex.format!("{ISO:Extended}"),
        username,
        user_id,
        Random.string()
      )

    config.http_client.post(url, body, headers(config))
  end

  defp commcare_api_case_url(commcare_domain, case_id) do
    "https://www.commcarehq.org/a/#{commcare_domain}/api/v0.5/case/#{case_id}/?format=json&child_cases__full=true"
  end

  defp commcare_api_user_url(commcare_domain, user_id) do
    "https://www.commcarehq.org/a/#{commcare_domain}/api/v0.5/user/#{user_id}/?format=json"
  end

  defp headers(%Config{api_token: api_token}) do
    [Authorization: "ApiKey #{api_token}"]
  end

  defp parse_response({:ok, %{status_code: 200, body: body}}), do: {:ok, Jason.decode!(body)}
  defp parse_response({:ok, %{status_code: 400}}), do: {:error, :commcare_data_error}
  defp parse_response({:ok, %{status_code: 401}}), do: {:error, :commcare_authorization_error}
  defp parse_response({:ok, %{status_code: 403}}), do: {:error, :commcare_forbidden}
  defp parse_response({:ok, %{status_code: 404}}), do: {:error, :not_found}
end
