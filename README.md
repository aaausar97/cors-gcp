

CREDS TO ORIGINAL CORS-ANYWHERE CREATOR. this repo contains my edits to original cors-anywhere repo to be used on a vm instance on gcp or container image. i had originally used the cors-anywhere repo on a heroku deployed service. i ended up having to move to another service and choose to try google cloud. had to make edits to the original repo to get it to work as seemlessly and deploy correctly.

I also created a Dockerfile and pushed a Docker image to make deployment to GCP even easier.

auqwar/cors-gcp [https://hub.docker.com/repository/docker/auqwar/cors-gcp/general]

here is a running example hosted here currently [as of nov 3 2024]: www.ausar.dev

**CORS Anywhere** is a NodeJS proxy which adds CORS headers to the proxied request.

Request examples:

* `http://localhost:8080/http://google.com/` - Google.com with CORS headers
* `http://localhost:8080/google.com` - Same as previous.
* `http://localhost:8080/google.com:443` - Proxies `https://google.com/`
* `http://localhost:8080/` - Shows usage text, as defined in `lib/help.txt`
* `http://localhost:8080/favicon.ico` - Replies 404 Not found

Live examples:

* https://cors-anywhere.herokuapp.com/
* https://robwu.nl/cors-anywhere.html - This demo shows how to use the API.

## Documentation

### Client

To use the API, just prefix the URL with the API URL. Take a look at [demo.html](demo.html) for an example.
A concise summary of the documentation is provided at [lib/help.txt](lib/help.txt).

**Note: as of February 2021, access to the demo server requires an opt-in**,
see: https://github.com/Rob--W/cors-anywhere/issues/301

If you want to automatically enable cross-domain requests when needed, use the following snippet:

```javascript
(function() {
    var cors_api_host = 'cors-anywhere.herokuapp.com';
    var cors_api_url = 'https://' + cors_api_host + '/';
    var slice = [].slice;
    var origin = window.location.protocol + '//' + window.location.host;
    var open = XMLHttpRequest.prototype.open;
    XMLHttpRequest.prototype.open = function() {
        var args = slice.call(arguments);
        var targetOrigin = /^https?:\/\/([^\/]+)/i.exec(args[1]);
        if (targetOrigin && targetOrigin[0].toLowerCase() !== origin &&
            targetOrigin[1] !== cors_api_host) {
            args[1] = cors_api_url + args[1];
        }
        return open.apply(this, args);
    };
})();
```

If you're using jQuery, you can also use the following code **instead of** the previous one:

```javascript
jQuery.ajaxPrefilter(function(options) {
    if (options.crossDomain && jQuery.support.cors) {
        options.url = 'https://cors-anywhere.herokuapp.com/' + options.url;
    }
});
```

### Server

The module exports `createServer(options)`, which creates a server that handles
proxy requests. The following options are supported:

* function `getProxyForUrl` - If set, specifies which intermediate proxy to use for a given URL.
  If the return value is void, a direct request is sent. The default implementation is
  [`proxy-from-env`](https://github.com/Rob--W/proxy-from-env), which respects the standard proxy
  environment variables (e.g. `https_proxy`, `no_proxy`, etc.).  
* array of strings `originBlacklist` - If set, requests whose origin is listed are blocked.  
  Example: `['https://bad.example.com', 'http://bad.example.com']`
* array of strings `originWhitelist` - If set, requests whose origin is not listed are blocked.  
  If this list is empty, all origins are allowed.
  Example: `['https://good.example.com', 'http://good.example.com']`
* function `handleInitialRequest` - If set, it is called with the request, response and a parsed
  URL of the requested destination (null if unavailable). If the function returns true, the request
  will not be handled further. Then the function is responsible for handling the request.
  This feature can be used to passively monitor requests, for example for logging (return false).
* function `checkRateLimit` - If set, it is called with the origin (string) of the request. If this
  function returns a non-empty string, the request is rejected and the string is send to the client.
* boolean `redirectSameOrigin` - If true, requests to URLs from the same origin will not be proxied but redirected.
  The primary purpose for this option is to save server resources by delegating the request to the client
  (since same-origin requests should always succeed, even without proxying).
* array of strings `requireHeader` - If set, the request must include this header or the API will refuse to proxy.  
  Recommended if you want to prevent users from using the proxy for normal browsing.  
  Example: `['Origin', 'X-Requested-With']`.
* array of lowercase strings `removeHeaders` - Exclude certain headers from being included in the request.  
  Example: `["cookie"]`
* dictionary of lowercase strings `setHeaders` - Set headers for the request (overwrites existing ones).  
  Example: `{"x-powered-by": "CORS Anywhere"}`
* number `corsMaxAge` - If set, an Access-Control-Max-Age request header with this value (in seconds) will be added.  
  Example: `600` - Allow CORS preflight request to be cached by the browser for 10 minutes.
* string `helpFile` - Set the help file (shown at the homepage).  
  Example: `"myCustomHelpText.txt"`

For advanced users, the following options are also provided.

* `httpProxyOptions` - Under the hood, [http-proxy](https://github.com/nodejitsu/node-http-proxy)
  is used to proxy requests. Use this option if you really need to pass options
  to http-proxy. The documentation for these options can be found [here](https://github.com/nodejitsu/node-http-proxy#options).
* `httpsOptions` - If set, a `https.Server` will be created. The given options are passed to the
  [`https.createServer`](https://nodejs.org/api/https.html#https_https_createserver_options_requestlistener) method.

For even more advanced usage (building upon CORS Anywhere),
see the sample code in [test/test-examples.js](test/test-examples.js).

### Demo server

A public demo of CORS Anywhere is available at https://cors-anywhere.herokuapp.com. This server is
only provided so that you can easily and quickly try out CORS Anywhere. To ensure that the service
stays available to everyone, the number of requests per period is limited, except for requests from
some explicitly whitelisted origins.

**Note: as of February 2021, access to the demo server requires an opt-in**,
see: https://github.com/Rob--W/cors-anywhere/issues/301

If you expect lots of traffic, please host your own instance of CORS Anywhere, and make sure that
the CORS Anywhere server only whitelists your site to prevent others from using your instance of
CORS Anywhere as an open proxy.

For instance, to run a CORS Anywhere server that accepts any request from some example.com sites on
port 8080, use:
```
export PORT=8080
export CORSANYWHERE_WHITELIST=https://example.com,http://example.com,http://example.com:8080
node server.js
```

