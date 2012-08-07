peoplevotal
===========

A Pivotal Tracker extension that breaks down tasks in current, backlog, and icebox by project members. Features a pretty dumb implementation I put together in a couple of hours.

## Running it
You will need to install the following gems:
* Sinatra: `gem install sinatra`
* JSON: `gem install json`
* Pivotal Tracker API Client: `gem install pivotal-tracker`

Run the app as follows:
`PIVOTAL_EMAIL=pivotaluser@example.com PIVOTAL_PASSWORD=example ruby main.rb`

In your favourite browser, go to:
`http://localhost:4567/`