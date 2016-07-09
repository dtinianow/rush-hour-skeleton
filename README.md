# Rush Hour
Project to explore database structure, table design, and database storage and retrieval, parsing of JSON data, MVC (models-views-controllers) design, HTTP, and basic principles surrounding the operation of a local server. The database is designed to hold HTTP header information and relate it to a client, the idea being that a client would be running JavaScript on their site that gathers a payload of header information about individual visitors to their site, which is then sent to our application as JSON and saved to that particular client.

Sinatra is used (in conjunction with shotgun) to manage routes and host a local server. ActiveRecord is utilized to interact with the database in an object-oriented manner. The database is built on PostgreSQL. Bootstrap is used for CSS styling of views.

Tables in the database are normalized down to second normal form.

## Usage
From the root folder of the project, run `shotgun` in the command line to launch a local server.

* To create a new client, send a POST request to `http://localhost:9393/sources`, passing an identifier and rootUrl. As a cURL request, this would look something like `$ curl -i -d 'identifier=jumpstartlab&rootUrl=http://jumpstartlab.com'  http://localhost:9393/sources`
  * Status responses and messages provide feedback based on the validity of the request.


* To add a payload request to an individual client, send a POST request to `http://localhost:9393/sources/:identifier/data`, where `:identifier` is replaced by the identifier of the client, passing a full payload request's data. As a cURL request, this would look something like:
`curl -i -d 'payload={"url":"http://jumpstartlab.com/blog","requestedAt":"2013-02-16 21:38:28 -0700","respondedIn":37,"referredBy":"http://jumpstartlab.com","requestType":"GET","userAgent":"Mozilla/5.0 (Macintosh%3B Intel Mac OS X 10_8_2) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1309.0 Safari/537.17","resolutionWidth":"1920","resolutionHeight":"1280","ip":"63.29.38.211"}' http://localhost:9393/sources/jumpstartlab/data`
  * Status responses and messages again provide feedback based on the validity of the payload and prior existence of a client.


* View pages are available for a client by its identifier, and also further analysis of individual paths of that client.
  * To view a client's data, send a GET request to `http://localhost:9393/sources/:identifier`, where `:identifier` is the client's identifier.
    * Available data includes:
      * Average Response time across all requests
      * Max Response time across all requests
      * Min Response time across all requests
      * Most frequent request type
      * List of all HTTP verbs used
      * List of URLs listed form most requested to least requested
      * Web browser breakdown across all requests
      * OS breakdown across all requests
      * Screen Resolutions across all requests (resolutionWidth x resolutionHeight)
  * To view a client's data by relative path, send a GET request to `http://localhost:9393/sources/:identifier/urls/:relativepath`, where `:identifier` is the client's identifier and `:relativepath` is the desired relative path.
    * Available data includes:
      * Max Response time
      * Min Response time
      * A list of response times across all requests listed from longest response time to shortest response time.
      * Average Response time for this URL
      * HTTP Verb(s) associated used to it this URL
      * Three most popular referrers
      * Three most popular user agents
