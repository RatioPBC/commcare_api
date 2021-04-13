{
  :ok,
  %HTTPoison.Response{
    body: "",
    headers: [
      {"Server", "nginx"},
      {"Date", "Wed, 13 May 2020 17:27:17 GMT"},
      {"Content-Type", "text/html; charset=utf-8"},
      {"Content-Length", "0"},
      {"Connection", "keep-alive"},
      {"HTTP_X_OPENROSA_VERSION", "1.0"},
      {"X-Frame-Options", "SAMEORIGIN"},
      {"Vary", "Accept-Language, Cookie"},
      {"Content-Language", "en"},
      {"Cache-Control", "private, no-cache, no-store, must-revalidate, proxy-revalidate"},
      {"Expires", "Thu, 01 Dec 1994 16:00:00 GMT"},
      {"Pragma", "no-cache"},
      {"Set-Cookie", "?=?; Path=/"},
      {
        "Set-Cookie",
        "sessionid=?; expires=Wed, 27-May-2020 17:27:17 GMT; HttpOnly; Max-Age=1209600; Path=/"
      }
    ],
    request: %HTTPoison.Request{
      body: "",
      headers: [
        Authorization: "ApiKey test-user:test-token"
      ],
      method: :get,
      options: [],
      params: %{},
      url: "https://www.commcarehq.org/a/ratio_pbc/api/v0.4/case/00000000-ad53-400d-bfe6-3e8f2a633293/?format=json"
    },
    request_url: "https://www.commcarehq.org/a/ratio_pbc/api/v0.4/case/00000000-ad53-400d-bfe6-3e8f2a633293/?format=json",
    status_code: 403
  }
}
