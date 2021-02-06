# OVERVIEW
The purpose of Linkvan is to connect people in need to the services they require.

linkvan-web is originally a Rails translation of Zendesk's awesome open source [linksf project](https://github.com/zendesk/linksf).

linkvan-web has now being splitted into a NExtJS frontend (https://github.com/linkvanproject/linkvan-web) and a Rails backend (https://github.com/linkvan/linkvan-api).

linkvan-api is developed in [Ruby on Rails 6.1](https://rubyonrails.org/) and is responsible for the admin interface and to expose an Rest API to the frontend.

The linkvan app is maintained by a community of volunteers based in Vancouver, Canada and the latest production version of the web app can be found at: https://linkvan.ca/


## Setting up an Environment
The [Ruby on Rails Guides](https://guides.rubyonrails.org/) will provide you instructions to help you install, configure and use Ruby on Rails.

Once you have installed and configured Ruby on Rails please fork the [linkvan-api app project repository](https://github.com/linkvan/linkvan-api) and clone it to your development computer.

To execute the app on your computer proceed as follows:

1. cd < directory where you cloned the project repository to >
2. Update your database configuration on `config/database.yml`
3. rails db:create (to create a database)
4. rails db:migrate
5. rails server
6. load http://localhost:3000/admin/dashboard on your web browser.


## Contributing to linkvan-web  
We want to make contributing to this project as easy and transparent as possible. By contributing to linkvan-API, you agree that your contributions can be used by the project and any others that fork the project at no cost.

We are always in need to contributions on documenting the platform, and the main efforts are now focused on implementing the admin interface.

Active development is done on `develop` branch.

## Our Development Process
We use GitHub to sync code to and from our internal repository. 

## Pull Requests
We actively welcome your pull requests.

If you wish to provide a contribution to the project please proceed as follows:

1. Fork the [linkvan-api repository](https://github.com/linkvan/linkvan-api) and create your branch from master.
2. Please ensure that your code passes all tests before you submit a Pull Request (PR).
3. Make sure your code lints.
4. Your PR should be submitted to the `develop` branch of the [linkvan-api repository](https://github.com/linkvan/linkvan-api).
5. A project administrator will evaluate your PR, suggest changes, and once approved, it will be merged into the master branch of the linkvan-web repository. 

## Issues
Linkvan uses Trello to manage the overall project backlog and tasks. If you would like to join the Trello board then please contact the project administrator to request access. We are studying switching to Github Issues to improve communication and a pilot program is initiating.

Thank you for your contribution to the project.
