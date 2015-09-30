# Zoho Projects Dashboard

Zoho Projects is a projects management tool that 
[Hoppinger](http://www.hoppinger.com) uses as a bug tracker for the Service &
Support department. The Service & Support department is responsible for the
maintainance of Hopppinger's projects. The Service & Support department needs a
way to monitor the amount of open bugs and feature requests. Because Zoho
Projects lacks a reporting tool that allows viewing of this data, we created our
own interface for this.

## Technical overview

The project can roughly be divided in three parts.

* A Ruby implementation of the 
  [Zoho Projects API](https://www.zoho.com/projects/help/rest-api/zohoprojectsapi.html). 
  The implementation only supports the reading operations of the API and is far
  from complete, but implements enough for our use case. This part lives in 
  `lib/zoho.rb` and `lib/zoho`.
* A Ruby script that uses the API implementation to extract the data that we
  need from Zoho Projects and writes this data to a JSON file. This part lives
  `bin/download`, `lib/dashboard.rb` and `lib/dashboard`. The JSON file is 
  written as `build/projects.json`.
* A HTML, CSS and JavaScript frontend that provides an interface to show the
  data in the JSON file as a fancy graph. This part lives in `build`.

## Installation

To get this project running, make a clone of the git repository. Then copy the
`config.example.yml` to `config.yml` and fill this with your configuration.

* `token` is the Zoho Projects API Auth Token. This token can be retrieved from
  Zoho Projects by logging in to the normal user interface of Zoho Projects and
  the point your browser to 
  https://accounts.zoho.com/apiauthtoken/create?SCOPE=ZohoProjects/projectsapi.
  This URL wil respond with a text file that contains the Auth Token.
* `portal_id` is the internal ID of the portal from which you want to extract
  the data. This one is a bit harder to retrieve, because the user interface of
  Zoho Projects does not show this ID anywhere, as far as I know. To make this
  a bit easier, I've created a simple script in `bin/portals` that shows you a
  list of the portals the user has access to. In order for this script to work,
  the `token` configuration property must already be present.
* `group_id` is the internal ID of the group the projects that are monitored
  belong to. This ID can be retrieved by running `bin/groups` when the `token`
  and the `portal_id` are filled. It will show a list of all the groups in the
  application (or rather all the groups that actually contain projects).
* `weeks` is how many of weeks of history will be retrieved by the script.