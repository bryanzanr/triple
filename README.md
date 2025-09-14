# Good Night –  System

## Ruby 3.3.5 (2024-09-03 revision ef084cc8f4)
## API (Rails 7.2.2.2 / PostgreSQL 17 Server 11.5 Client)

## How the Applications Work

The web-application is based on Ruby on Rails (RoR) Backend Framework. It's implemented through Representational State Transfer Application Program Interface (REST-API). The assumptions that has been made are as follows:

![Database design](Untitled.png)

1. API-only Rails app (Rails 7+), Postgres DB.
2. No auth/registration needed because auth is simulated by passing X-User-Id header to identify the current user.
3. A user can have at most one open clock-in (sleep record without ended_at).
4. "Previous week" means the previous calendar week (Mon 00:00 → Sun 23:59:59) in Asia/Jakarta timezone. 
5. Timestamps (data created or updated date format) are stored in standard UTC and compute windows in the app timezone.
5. Sleep duration is computed in seconds and stored for fast sorting.
6. Most of the variable is styled in snake case (best practice in this programming language).
7. Each of the entity will have their own implementation (Model & Controller).
8. The sleep records can be edited thorugh PATCH instead of PUT API if it's only a single attribte (despite both are supported). 

More detailed information can be found [here](BE%20interview%20homework_v2%20(1)%20(2)%20(1).pdf) or in the source code itself (above each of the method / function).

Design Decision:
* Execute rails new good_night --api -d postgresql (for create a fresh API-only app).
* Execute bundle add rspec-rails factory_bot_rails faker database_cleaner-active_record (for testing and helper gems).
* Execute rails generate rspec:install (for initialize the RSpec).
* Prepare the Gemfile (for key gems), config/application.rb, and config/routes.rb.
* Prepare the  schema and migration in db/migration (users, follows, and sleep_records).
* Prepare the models in app/models (user, follow, sleep_record).
* Prepare the controllers and serialization in app/controllers (main application, user that include follow flow / mechanism, sleep_record that includes clock in / out action). 
* Execute rails db:create (to validate the created model / schema if not existed yet, if already existed can execute rails db:drop first which later will create database good_night_development for the app and good_night_test for the spec).
* Execute rails db:migrate (to generate the initial migration that include the necessary index in the models into the previous created databases which will be saved in db/schema.rb).
* Execute rails db:seed (to populate the data from db/seeds.rb which will also remove all of the existing data if any)
* Prepare the unit tests for previous models (spec/models/) and controllers (spec/requests/). 
* Execute bundle exec rspec (to check all the unit tests or add the file in the end of statement if wanted to be specific)
* Execute rails generate rswag:api:install to generate config/initializers/rswag_api.rb and configure the API for /api-docs in the routes (after adding the library in the Gemfile). 
* Execute rails generate rswag:ui:install to generate config/initializers/rswag_ui.rb and configure the UI for /api-docs in the routes. 
* Execute rails generate rswag:specs:install to generate spec/swagger_helper.rb for adjust the default URL to http://localhost:3000 instead of https://www.example.com
* Execute bundle exec rake rswag:specs:swaggerize to generate generate OpenAPI JSON files in swagger/v1/swagger.yaml based on the spec/integration
* Create docker-compose.yml for running through container.
* Create README.md for explaining about setup instructions, architecture explanation, and important note. 
* Create .gitignore for excluding the generated / binary files. 
* Refactor and testing.  

## Getting Started (How to Run the Program)

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites (How to set up your machine)

1. Navigate to the directory where you've cloned this repo and setting up the docker and database first (can also populate manually or directly using SQL if necessary).

    ```sql
    INSERT INTO users (name, created_at, updated_at)
    VALUES
    ('Alice', NOW(), NOW()),
    ('Bob', NOW(), NOW()),
    ('Charlie', NOW(), NOW());
    ```

2. In the directory where you've cloned this repo, move into the good_night/ folder for installing all its dependencies (if using docker can be done through `docker-compose build`).

    ```bash
    bundle install
    ```

    Dependencies are all listed in `Gemfile`.

3. Execute `rails db:prepare` (for doing the migration first) and run the app (if using docker can be done through `docker-compose up --build` for starting the service). 

    ```bash
    rails server
    ```

4. The app is now running! To check that the web is actually running,
try to send a GET request to it, for instance (or you can also execute `rails c` for opening the console directly to test):

    ```bash
    curl http://127.0.0.1:3000
    ```

    or open `http://localhost:3000` from your browser.

### Installing (How to check and test the program using Docker)

1. If you're using docker, make sure you already pull the docker images and run the container. Both are listed in `Dockerfile` and `docker-compose.yml` so if you followed the instructions to setup your machine above then they should already be installed and running. 
2. After the container is running, you can run seeds using `docker-compose exec web rails db:seed`
3. You can run the check for running container ID with `docker ps` and for the installed images with `docker images` respectively.
4. To run the Postgre Structured Query Language (PostgreSQL) console in one command, you can use `psql`. This is useful to check the database directly.
5. For more info on what you can do with `docker`, run `docker --help`.

## Documentation

### User

* [Index](#index)
* [Show](#show)
* [Follow](#follow)
* [Unfollow](#unfollow)
* [Following Sleep Records](#following)

### Sleep Record

* [List](#list)
* [Create](#create)
* [Update](#update)
* [Detail](#detail)

### Other
* [Clock In](#in)
* [Clock Out](#out)

## Index
URL: GET - `http://localhost:3000/api/users?page=&items=`

Example Response Body (based on the initial SQL):

```json
[
    {
        "id": 1,
        "name": "Alice",
        "created_at": "2025-09-11T00:13:48.251+07:00",
        "updated_at": "2025-09-11T00:13:48.251+07:00"
    },
    {
        "id": 2,
        "name": "Bob",
        "created_at": "2025-09-11T00:13:48.264+07:00",
        "updated_at": "2025-09-11T00:13:48.264+07:00"
    },
    {
        "id": 3,
        "name": "Charlie",
        "created_at": "2025-09-11T00:13:48.271+07:00",
        "updated_at": "2025-09-11T00:13:48.271+07:00"
    }
]
```

## Show
URL: GET - `http://localhost:3000/api/users/:id`

Example Response Body (based on the initial SQL and with id = 1):

```json
{
    "id": 1,
    "name": "Alice",
    "created_at": "2025-09-11T00:13:48.251+07:00",
    "updated_at": "2025-09-11T00:13:48.251+07:00"
}
```

## Follow
URL: POST - `http://localhost:3000/api/users/:id/follow`

Example Response Body (X-User-Id on request header = 1 & id = 2):

```json
{
    "ok": true
}
```

## Unfollow
URL: DELETE - `http://localhost:3000/api/users/:id/unfollow`

Example Response Body:

```json
{
    "ok": true
}
```

## Following
URL: GET - `http://localhost:3000/api/users/following_sleep_records?page=1&items=1`

Example Response Body (with seed data instead of just initial SQL):

```json
[
    {
        "id": 3,
        "user_id": 5,
        "user_name": "Bob",
        "started_at": "2025-09-02T22:00:00.000+07:00",
        "ended_at": "2025-09-03T05:00:00.000+07:00",
        "duration_sec": 25200
    }
]
```

## List
URL: GET - `http://localhost:3000/api/sleep_records?page=1&items=1`

Example Response Body (after successful clock in):

```json
[
    {
        "id": 1,
        "user_id": 1,
        "started_at": "2025-09-11T00:27:56.585+07:00",
        "ended_at": null,
        "duration_sec": null,
        "created_at": "2025-09-11T00:27:56.597+07:00",
        "updated_at": "2025-09-11T00:27:56.597+07:00"
    }
]
```

## Create
URL: POST - `http://localhost:3000/api/sleep_records`

Example Request Body (for add new record without in and out):

```json
{
    "sleep_record": {
        "started_at": "2025-09-12T00:27:56.585+07:00",
        "ended_at": "2025-09-13T00:27:56.585+07:00"
    }
}
```

## Update
URL: PATCH / PUT - `http://localhost:3000/api/sleep_records/:id`

Example Response Body (after successful update):

```json
{
    "user_id": 1,
    "started_at": "2025-09-10T00:27:56.585+07:00",
    "duration_sec": 86739,
    "id": 1,
    "ended_at": "2025-09-11T00:33:35.817+07:00",
    "created_at": "2025-09-11T00:27:56.597+07:00",
    "updated_at": "2025-09-11T00:47:54.068+07:00"
}
```

## Detail
URL: GET - `http://localhost:3000/api/sleep_records/:id`

Example Response Body (after successful clock out):

```json
{
    "id": 1,
    "user_id": 1,
    "started_at": "2025-09-11T00:27:56.585+07:00",
    "ended_at": "2025-09-11T00:33:35.817+07:00",
    "duration_sec": 339,
    "created_at": "2025-09-11T00:27:56.597+07:00",
    "updated_at": "2025-09-11T00:33:35.819+07:00"
}
```

## In
URL: POST - `http://localhost:3000/api/clock_in`

Example Response Body (with X-User_Id header = 1 and have never execute the request before out first):

```json
{
    "record": {
        "id": 1,
        "user_id": 1,
        "started_at": "2025-09-11T00:27:56.585+07:00",
        "ended_at": null,
        "duration_sec": null,
        "created_at": "2025-09-11T00:27:56.597+07:00",
        "updated_at": "2025-09-11T00:27:56.597+07:00"
    },
    "open_clock_ins": [
        {
            "id": 1,
            "user_id": 1,
            "started_at": "2025-09-11T00:27:56.585+07:00",
            "ended_at": null,
            "duration_sec": null,
            "created_at": "2025-09-11T00:27:56.597+07:00",
            "updated_at": "2025-09-11T00:27:56.597+07:00"
        }
    ]
}
```

## Out
URL: POST - `http://localhost:3000/api/clock_out`

Example Response Body (with X-User_Id header = 1 which will also reflect in the list if execute again):

```json
{
    "user_id": 1,
    "ended_at": "2025-09-11T00:33:35.817+07:00",
    "duration_sec": 339,
    "id": 1,
    "started_at": "2025-09-11T00:27:56.585+07:00",
    "created_at": "2025-09-11T00:27:56.597+07:00",
    "updated_at": "2025-09-11T00:33:35.819+07:00"
}
```

Postman's API Documentation can be found [here](triple.postman_collection.json).

## Built With

* [Ruby on Rails](https://rubyonrails.org/) - The web framework used in this backend development language
* [PostgreSQL](https://www.postgresql.org/) - Used to generate the database

## Authors

* **Bryanza Novirahman** - *Software Engineer with approximately 6 years of experience* - [LinkedIn](https://www.linkedin.com/in/bryanza-novirahman-902a94131)

## Important links
* [Docker](https://www.docker.com)