# Zoho Projects Dashboard

Zoho Projects is a project management tool that 
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

## Assumptions

The script is quite heavily targeted at our usage of Zoho Projects. A few
notable things that are hardcoded in this script:

* We use the `module` property of a bug to indicate whether it is a Bug, 
  Feature Request or Task.
* All the projects that we want to monitor are in a single portal and are
  placed in a group in this portal.
* We monitor per week.

## Installation

To get this project running, make a clone of the git repository. 

Run

```bash
bundle install
```

to make sure all the dependencies are installed. 

Then copy the `config.example.yml` to `config.yml` and fill this with your 
configuration.

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
* `weeks` is how many of weeks of history will be retrieved by the script. Read
  the part about how the data is gathered in this file to find out more about
  this.

Now that you've configured the script, you'll need to run it. Run

```bash
./bin/download
```

to retrieve the data from Zoho Projects and save the `build/projects.json` file.
This can take quite a while. We download ten weeks of data for a little over a
hundred projects, in about 10 to 15 minutes. The script sends a lot of requests
to the Zoho Projects API, and the API is not very fast.

The last step is to get a webserver running that uses `build` as the document
root. Directly opening `build/index.html` in your browser does not work, because
the JavaScript code loads the JSON file using AJAX, which doesn't work without
HTTP.

## Data retrieval

The script gathers all the projects from Zoho Projects. Then it filters out the
projects in the group. For every project we run the following analyzing
procedure.

We download a list of all bugs for the project. We map this list of bugs to a
hash. The keys are the bug ids, the values are also hashes with following 
properties:
* `opened_at`: DateTime - The moment the bug was opened
* `closed`: Boolean - Whether the bug is currently closed
* `type`: Symbol - `:feature_request`, `:bug` or `:task`.

The bug object that the API returns does not contain information about when the
bug was closed. So we need another way to figure this out. We do this by
analysing the activity stream from Zoho Project. This activity stream can only
be retrieved per project, so we need to map the activity to bugs ourselves.

We loop over the activities (starting at the most recent activity). We only look
at activities that indicate a status change of a bug that is currently closed
and does not already have `closed_at` property. If we find such an activity we
register the time as the activity in the `closed_at` property of the matching
bug. After we have set this property we do not change it anymore. This means 
that we assume that the latest status change of a closed bug is the moment is 
was closed. 

We are only interested in data for the previous x (in our case 10) weeks. We
handle this by creating 10 objects that represent the past 10 full weeks. We
call these objects time buckets. When we reach an activity that occured before 
the start of the first week, we stop looping. We also stop looping when all the
closed bugs in the list already have a `closed_at` property.

After we have analyzed the actvities we loop over the bugs and push every bug
in all of the time buckets. Each of the buckets knows it's own start and end
time, so the buckets can determine whether the bug was **open** or **closed** at
the end of the week, and whether the bug was **opened88 or 88closed88 during the
week. For each of the possible values of the `type` property, the bucket keeps a
counter for each of the states we listed.

Finally this structure of projects, that contain buckets and the counters of
these states per type is exported to JSON.

