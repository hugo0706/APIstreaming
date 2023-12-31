# APIstreaming


## Table of Contents

### 🌐   Core Sections
- **[Introduction](#introduction)**
- **[Assumptions](#assumptions)**
- **[Versions](#versions)**
- **[🚀 How to Deploy](#how-to-deploy)**
  - [Local Development](#local-development)

### ⚙️  Project Configuration
- **[Project Structure](#project-structure)**
  - [Schema](#schema)
  - [Relationships](#relationships)
  - [Polymorphism](#polymorphism)
  - [Folder Structure](#folder-structure)

### 🗄 Data Handling
- **[Caching Strategy](#caching-strategy)**
  - [Invalidation](#invalidation)

### 🧪 Testing
- **[Tests](#tests)**
  - [Coverage](#coverage)
  - [RSpec Tests](#rspec-tests)

### 🛠 API Endpoints
- **[Endpoints](#endpoints)**
  - **Movies**
    - [🔍 GET /movies](#get-movies)
    - [➕ POST /movies](#post-movies)
    - [❌ DELETE /movies](#delete-movies)
  - **Seasons**
    - [🔍 GET /seasons](#get-seasons)
    - [➕ POST /seasons](#post-seasons)
    - [❌ DELETE /seasons](#delete-seasons)
  - **Catalog**
    - [🔍 GET /catalog](#get-catalog)
  - **Purchase**
    - [➕ POST /purchase](#post-purchase)
  - **Library**
    - [🔍 GET /profile/library](#get-profilelibrary)
---

## Introduction

This project simulates a RESTful API for a streaming service. The API handles various requests, including listing available movies, seasons, and the entire catalog offered by the service. It also manages user libraries and handles purchase requests.

  
## Assumptions

- 10 movie/seasons added every week
- Users can buy the same content in different qualities
- Cache has to be invalidated upon arrival of new content
- User library needs 100% data accuracy
- User authentication is not required, user_id can be used to identify
- Episodes within a season should have unique numbers

---

## Versions

### Ruby version
- ruby 3.0.6

### Rails version
- Rails 7.0.7.2

### Database
- PostgreSQL 15.2
- Redis 7.0.11

---

## How to Deploy

### Local Development

1. **Clone the Repository**

    ```bash
    git clone https://github.com/hugo0706/APIstreaming.git
    ```

2. **Set Up Environment Variables**

    Create a `.env` file on project's root and add your environment variables.
    ```bash
    PGUSER='user'
    PGPWD='pwd'
    REDIS_URL=redis://localhost:6379
    ```

3. **Bundle Install**

    ```bash
    bundle install
    ```

4. **Database Setup**

    ```bash
    rails db:create
    rails db:migrate
    ```
5. **Populate Database (optional)**
   ```bash
   rails db:seed
   ```
6. **Run redis server**
   ```bash
   redis-server
   ```
7. **Run the Server**

    ```bash
    rails server
    ```

---

## Project Structure

### Schema

The schema of the project is composed by 6 tables: 

1. **Episodes**
   - `title`: String
   - `plot`: Text
   - `number`: Integer
   - `season_id`: Foreign Key (Season)
   - Timestamps (`created_at`, `updated_at`)

2. **Movies**
   - `title`: String
   - `plot`: Text
   - Timestamps (`created_at`, `updated_at`)

3. **Purchase Options**
   - `optionable_type`: String (Polymorphic)
   - `optionable_id`: Integer (Polymorphic)
   - `price`: Decimal
   - `quality`: String
   - Timestamps (`created_at`, `updated_at`)

4. **Purchases**
   - `user_id`: Foreign Key (User)
   - `purchasable_type`: String (Polymorphic)
   - `purchasable_id`: Integer (Polymorphic)
   - `purchase_option_id`: Foreign Key (Purchase Option)
   - `expires_at`: Datetime
   - Timestamps (`created_at`, `updated_at`)

5. **Seasons**
   - `title`: String
   - `plot`: Text
   - `number`: Integer
   - Timestamps (`created_at`, `updated_at`)

6. **Users**
   - `email`: String
   - Timestamps (`created_at`, `updated_at`)

### Relationships

- Episodes belong to Seasons (`season_id` is the foreign key)
- Purchase Options are polymorphic and can belong to either Movies or Seasons (`optionable_type`, `optionable_id`)
- Purchases have a foreign key to Users (`user_id`) and to Purchase Options (`purchase_option_id`) and are also polymorphic (`purchasable_type`, `purchasable_id`), linking them to either Movies or Seasons

### Polymorphism

I opted for a **polymorphic** design instead of a unifying `Content` table for `Movie` and `Season`. This approach is **DRY**, **scalable**, and keeps the **schema simple**. Any content type can be made purchasable with a straightforward `purchasable` association. 

Instead of relying on a parent table for shared attributes, I use a Rails **Concern** called **`VideoContentConcern`**. This concern encapsulates common functionalities like being `purchasable` and having associated purchases, providing a modular and extendable structure for different content types.


### Folder structure

- `app/controllers/` - Where the controller files are.
- `app/controllers/concerns/`: Contains concerns included in controllers, such as `ErrorHandler`.
- `app/models/`: Location for the model files.
- `app/models/concerns`: Contains concerns used in models, including the previously mentioned `VideoContentConcern`.
- `app/serializers/`: Holds serializer classes responsible for data serialization.
- `app/services/`: Features service classes utilized by controllers to maintain DRY and clear code.
- `config/` - App configurations and routes.
- `db/` - Database schema and migrations.
- `spec/` - Rspec test suite.

---
## Caching strategy
Information cached on redis includes the responses given to `get` requests performed on  ``/movies`` and `/seasons` endpoints. This information contains all movies and seasons respectively.
### Invalidation
**Content Cache**
Given the moderate rate of content updates (approximately 10 additions per week), the cache is invalidated and updated under the following scenarios:

- A movie is added or deleted
- A season is added or deleted

`/catalog` endpoint retrieves data from cached movies and seasons, forming the whole catalog.
This way data is always up to date.

**User Library**

To ensure 100% data accuracy, the user library is not cached and is updated instantly upon request.

---
## Tests

To run tests simply use

```bash
rspec
```
To see coverage results after desploying tests use
```bash
open coverage/index.html
```
### Coverage
Coverage given by SimpleCov:
All Files ( 99.32% covered at 2.32 hits/line )
50 files in total.
876 relevant lines, 870 lines covered and 6 lines missed. ( 99.32% )

### Rspec tests

```markdown
### Controllers
#### Catalog
  GET /index
    when movies and seasons exist
      returns a list of movies and seasons with status :ok
    when movies and seasons dont exist
      returns empty array with status :ok

#### Movies
  GET /index
    when movies exist
      returns a list of movies with status :ok
    when movies dont exist
      returns empty array with status :ok
    when ActiveRecord::RecordNotFound is raised
      returns error message with status :not_found
    when StandardError is raised
      returns error message with status :internal_server_error
  POST /create
    when params are correct
      creates a new Movie
      invalidates the cache
      returns created status and the new movie as JSON
    when params lack movie key
      does not create a new Movie
      returns unprocessable_entity status and error message
    when other param is incorrect
      doesnt create a new Movie
      returns json with error and status :unprocessable_entity
  DELETE /destroy
    when movie exists
      deletes the movie
      deletes the movie purchases
      deletes the movie purchase_options

#### Purchases
  POST /purchase
    when purchase is a movie
      creates a purchase
      returns a purchased movie and status :created
    when purchase is a season
      creates a purchase
      returns a purchased season and status :created
    when params are empty
      returns error status 422
    when movie doesnt exist
      returns error status not found
    when season doesnt exist
      returns error status not fount
    when purchase option doesnt exist
      returns error status not found
    when user doesnt exist
      returns error status unprocessable_entity
    when trying to purchase a movie twice
      returns error Purchase option has already been taken status 422
    when trying to purchase a movie twice with 2 days in between
      returns a purchased movie and status :created

#### Seasons
  GET /index
    when seasons exist
      returns a list of seasons with status :ok
    when seasons dont exist
      returns empty array with status :ok
    when ActiveRecord::RecordNotFound is raised
      returns error message with status :not_found
    when StandardError is raised
      returns error message with status :internal_server_error
  POST /create
    when params are correct
      creates a new Season
      invalidates the cache
      returns created status and the new season as JSON
    when params are incorrect
      does not create a new Season
      returns unprocessable_entity status and error message
  DELETE /destroy
    when season exists
      deletes the season
      deletes the season purchases
      deletes the season purchase_options

#### Users
  GET /profile/library
    when user has purchases
      returns a list of seasons/movies with status :ok
    when user has no purchases
      returns empty array with status :ok
    when user checks purchases older than 2 days
      purchasables dissapear with status :ok
### Services
#### CatalogService
  .get_catalog
    returns a list of available movies and seasons
  .get_catalog_ordered
    returns a combined and ordered list of movies and seasons by creation date

#### MovieService
  .get_movies_by_descending_creation
    when movies exist
      returns a list of available movies
      fetches the list of movies from the cache
    when movies dont exist
      returns an empty list
  .purchase_movie
    when successful
      creates a new purchase
    when movie is not found
      doesnt persist the purchase
    when purchase option is not found
      doesnt persist the purchase

#### SeasonService
  .get_seasons_desc_episodes_asc
    when seasons exist
      returns a list of available seasons
      fetches the list of season from the cache
    when seasons dont exist
      returns an empty list
  .invalidate_cache
    invalidates the cache
  .purchase_season
    when successful
      creates a new purchase
    when season is not found
      doesnt persist the purchase
    when purchase option is not found
      doesnt persist the purchase

## Models
### Episode
  validations
    is valid with correct params
    is not valid without a title
    is not valid without a plot
    is not valid without a number
    is not valid with a negative number, zero or float
    is not valid with a repeated number within the same season

### Movie
  validations
    is valid with correct params
    is not valid without a title
    is not valid without a plot

### PurchaseOption
  validations
    is valid with correct params
    is valid with price 0
    is not valid without a price
    is not valid with a negative price
    is not valid without a quality
    is not valid with a quality not in [HD, SD]

### Purchase
  validations
    is valid with valid attributes
    is valid without an expires_at beacuse default is used
    is not valid without a unique purchase_option_id

### Season
  validations
    is valid with correct params
    is not valid without a title
    is not valid without a plot
    is not valid without a number
    is not valid with a negative number, zero or float

### User
  validations
    is valid with a unique email
    is not valid without an email
    is not valid with a repeated email

```

---

## Endpoints

### GET /movies

Description:

Returns the movie list ordered by newest

Request:
```bash
curl -X GET localhost:3000/movies
```

Response example:
```json
[
    {
        "id": 6,
        "type": "movie",
        "title": "Movie 2",
        "plot": "Movie 2",
        "created_at": "2023-08-30T08:52:59.267Z",
        "updated_at": "2023-08-30T08:52:59.267Z",
        "purchase_options": [
            {
                "id": 15,
                "price": "9.99",
                "quality": "SD"
            },
            {
                "id": 16,
                "price": "9.99",
                "quality": "SD"
            }
        ]
    },
    {
        "id": 5,
        "type": "movie",
        "title": "Movie 1",
        "plot": "Movie 1",
        "created_at": "2023-08-30T08:52:12.588Z",
        "updated_at": "2023-08-30T08:52:12.588Z",
        "purchase_options": [
            {
                "id": 14,
                "price": "9.99",
                "quality": "HD"
            }
        ]
    }
]
```

### POST /movies

Description: 

Creates a movie record

Request:
```bash
curl -X POST localhost:3000/movies -d 'params'
```
Parameter format:
```json
{
  "movie": {
    "title": "movie",
    "plot": "as",
    "purchase_options_attributes": [
        {
        "price": 2.99,
        "quality": "HD"
        }
    ]
  }
}
```

Response `201 Created`:
```json
{
    "id": 7,
    "type": "movie",
    "title": "movie",
    "plot": "as",
    "created_at": "2023-08-30T18:33:22.795Z",
    "updated_at": "2023-08-30T18:33:22.795Z",
    "purchase_options": [
        {
            "id": 20,
            "price": "2.99",
            "quality": "HD"
        }
    ]
}
```

### DELETE /movies

Description:
Deletes a movie record
Request:
```bash
curl -X DELETE localhost:3000/movies/{movie_id}
```
Response:
``204 No content``

### GET /seasons

Description:
Returns the season list ordered by newest with their respective episodes ordered by number

Request:
```bash 
curl -X GET localhost:3000/seasons
```
Response: ``200 ok``

```json
[
    {
        "id": 6,
        "type": "season",
        "title": "season",
        "number": 1,
        "plot": "as",
        "created_at": "2023-08-30T10:51:14.622Z",
        "updated_at": "2023-08-30T10:51:14.622Z",
        "episodes": [
            {
                "type": "episode",
                "id": 9,
                "title": "EP1",
                "number": 1,
                "plot": "PLOT",
                "created_at": "2023-08-30T10:51:14.632Z"
            },
            {
                "type": "episode",
                "id": 10,
                "title": "EP2",
                "number": 2,
                "plot": "PLOT",
                "created_at": "2023-08-30T10:51:14.640Z"
            }
        ],
        "purchase_options": [
            {
                "id": 19,
                "optionable_type": "Season",
                "optionable_id": 6,
                "price": "3.99",
                "quality": "SD",
                "created_at": "2023-08-30T10:51:14.631Z",
                "updated_at": "2023-08-30T10:51:14.631Z"
            },
            {
                "id": 18,
                "optionable_type": "Season",
                "optionable_id": 6,
                "price": "2.99",
                "quality": "HD",
                "created_at": "2023-08-30T10:51:14.627Z",
                "updated_at": "2023-08-30T10:51:14.627Z"
            }
        ]
    },
    {
        "id": 4,
        "type": "season",
        "title": "Season 1",
        "number": 1,
        "plot": "Season 1",
        "created_at": "2023-08-30T08:51:12.967Z",
        "updated_at": "2023-08-30T08:51:12.967Z",
        "episodes": [
            {
                "type": "episode",
                "id": 7,
                "title": "EP 1",
                "number": 1,
                "plot": "EP 1",
                "created_at": "2023-08-30T08:51:13.157Z"
            }
        ],
        "purchase_options": [
            {
                "id": 12,
                "optionable_type": "Season",
                "optionable_id": 4,
                "price": "9.99",
                "quality": "SD",
                "created_at": "2023-08-30T08:51:13.198Z",
                "updated_at": "2023-08-30T08:51:13.198Z"
            }
        ]
    }
    
]
```

### POST /seasons

Description:
Request:
```bash
curl -X POST localhost:3000/seasons -
```
Params:
```json
{
  "season": {
    "title": "season",
    "plot": "plot",
    "number": 1,
    "purchase_options_attributes": [
        {
        "price": 2.99,
        "quality": "HD"
        },
        {
        "price": 3.99,
        "quality": "SD"
        }
    ],
    "episodes_attributes": [
        {
        "title": "EP1",
        "plot": "PLOT",
        "number": 1
        },
        {
        "title": "EP2",
        "plot": "PLOT",
        "number": 2
        }
    ]
  }
}
``````
Response: `201 created`
```json
{
    "id": 7,
    "type": "season",
    "title": "season",
    "number": 1,
    "plot": "plot",
    "created_at": "2023-08-30T20:22:39.698Z",
    "updated_at": "2023-08-30T20:22:39.698Z",
    "episodes": [
        {
            "type": "episode",
            "id": 11,
            "title": "EP1",
            "number": 1,
            "plot": "PLOT",
            "created_at": "2023-08-30T20:22:39.705Z"
        },
        {
            "type": "episode",
            "id": 12,
            "title": "EP2",
            "number": 2,
            "plot": "PLOT",
            "created_at": "2023-08-30T20:22:39.710Z"
        }
    ],
    "purchase_options": [
        {
            "id": 21,
            "optionable_type": "Season",
            "optionable_id": 7,
            "price": "2.99",
            "quality": "HD",
            "created_at": "2023-08-30T20:22:39.703Z",
            "updated_at": "2023-08-30T20:22:39.703Z"
        },
        {
            "id": 22,
            "optionable_type": "Season",
            "optionable_id": 7,
            "price": "3.99",
            "quality": "SD",
            "created_at": "2023-08-30T20:22:39.704Z",
            "updated_at": "2023-08-30T20:22:39.704Z"
        }
    ]
}
```

### DELETE /seasons

Description:
Destroys a season record
```bash
curl -X DELETE localhost:3000/season/{season_id}
```
Response:
``204 No content``

### GET /catalog

Description:
Returns a list of movies and seasons, ordered by creation
Request:
```bash
curl -X GET localhost:3000/catalog
```
Response: `200 ok``
```json
[
    {
        "id": 7,
        "type": "movie",
        "title": "movie",
        "plot": "as",
        "created_at": "2023-08-30T18:33:22.795Z",
        "updated_at": "2023-08-30T18:33:22.795Z",
        "purchase_options": [
            {
                "id": 20,
                "price": "2.99",
                "quality": "HD"
            }
        ]
    },
    {
        "id": 6,
        "type": "movie",
        "title": "Movie 2",
        "plot": "Movie 2",
        "created_at": "2023-08-30T08:52:59.267Z",
        "updated_at": "2023-08-30T08:52:59.267Z",
        "purchase_options": [
            {
                "id": 15,
                "price": "9.99",
                "quality": "SD"
            },
            {
                "id": 16,
                "price": "9.99",
                "quality": "SD"
            },
            {
                "id": 17,
                "price": "9.99",
                "quality": "SD"
            }
        ]
    },
    {
        "id": 5,
        "type": "season",
        "title": "Season 2",
        "number": 2,
        "plot": "Season 2",
        "created_at": "2023-08-30T08:51:24.193Z",
        "updated_at": "2023-08-30T08:51:24.193Z",
        "episodes": [
            {
                "type": "episode",
                "id": 8,
                "title": "EP 2",
                "number": 2,
                "plot": "EP 2",
                "created_at": "2023-08-30T08:51:24.197Z"
            }
        ],
        "purchase_options": [
            {
                "id": 13,
                "optionable_type": "Season",
                "optionable_id": 5,
                "price": "9.99",
                "quality": "SD",
                "created_at": "2023-08-30T08:51:24.199Z",
                "updated_at": "2023-08-30T08:51:24.199Z"
            }
        ]
    },
    {
        "id": 4,
        "type": "season",
        "title": "Season 1",
        "number": 1,
        "plot": "Season 1",
        "created_at": "2023-08-30T08:51:12.967Z",
        "updated_at": "2023-08-30T08:51:12.967Z",
        "episodes": [
            {
                "type": "episode",
                "id": 7,
                "title": "EP 1",
                "number": 1,
                "plot": "EP 1",
                "created_at": "2023-08-30T08:51:13.157Z"
            }
        ],
        "purchase_options": [
            {
                "id": 12,
                "optionable_type": "Season",
                "optionable_id": 4,
                "price": "9.99",
                "quality": "SD",
                "created_at": "2023-08-30T08:51:13.198Z",
                "updated_at": "2023-08-30T08:51:13.198Z"
            }
        ]
    }
]
```

### POST /purchase
Description:
Creates a purchase record, returns the purchase data.
Request:
```bash
curl -X POST localhost:3000/purchase -d 'params'
```
Params:
```json
{
  "purchase": {
    "purchasable_type": "Season", #can  also be Movie
    "purchasable_id": 3,
    "user_id": 1,
    "purchase_option_id": 11
  }
}
```

Response: `201 created`
```json 
{
    "id": 20,
    "user_id": 1,
    "email": "email",
    "title": "Season 2",
    "purchase_option": {
        "id": 13,
        "price": "9.99",
        "quality": "SD"
    },
    "purchasable_type": "Season",
    "purchasable_id": 5,
    "expires_at": "2023-09-01T20:37:54.379Z",
    "created_at": "2023-08-30T20:37:54.381Z",
    "updated_at": "2023-08-30T20:37:54.381Z"
}
```

### GET /profile/library

Description:
Lists users purchased content by least time left to consume

Request:
```bash
curl -X GET localhost:3000/profile/library?user_id={id}
```

Response:
```json
[
    {
        "purchasable": {
            "id": 1,
            "type": "movie",
            "title": "Movie 1",
            "plot": "Movie 1",
            "created_at": "2023-08-31T14:04:57.052Z",
            "updated_at": "2023-08-31T14:04:57.052Z",
            "purchase_options": [
                {
                    "id": 1,
                    "price": "9.99",
                    "quality": "SD"
                }
            ]
        },
        "purchased_option": {
            "id": 1,
            "optionable_type": "Movie",
            "optionable_id": 1,
            "price": "9.99",
            "quality": "SD",
            "created_at": "2023-08-31T14:04:57.062Z",
            "updated_at": "2023-08-31T14:04:57.062Z"
        },
        "expires_at": "2023-09-01T21:16:57.027Z"
    },
    {
        "purchasable": {
            "id": 2,
            "type": "movie",
            "title": "Movie 2",
            "plot": "Movie 2",
            "created_at": "2023-08-31T14:04:57.088Z",
            "updated_at": "2023-08-31T14:04:57.088Z",
            "purchase_options": [
                {
                    "id": 2,
                    "price": "9.99",
                    "quality": "SD"
                }
            ]
        },
        "purchased_option": {
            "id": 2,
            "optionable_type": "Movie",
            "optionable_id": 2,
            "price": "9.99",
            "quality": "SD",
            "created_at": "2023-08-31T14:04:57.091Z",
            "updated_at": "2023-08-31T14:04:57.091Z"
        },
        "expires_at": "2023-09-01T21:16:57.027Z"
    },
    {
        "purchasable": {
            "id": 1,
            "type": "season",
            "title": "Season 1",
            "number": 1,
            "plot": "Season 1",
            "created_at": "2023-08-31T14:04:57.104Z",
            "updated_at": "2023-08-31T14:04:57.104Z",
            "episodes": [
                {
                    "type": "episode",
                    "id": 1,
                    "title": "EP 1",
                    "number": 1,
                    "plot": "EP 1",
                    "created_at": "2023-08-31T14:04:57.122Z"
                }
            ],
            "purchase_options": [
                {
                    "id": 3,
                    "optionable_type": "Season",
                    "optionable_id": 1,
                    "price": "9.99",
                    "quality": "SD",
                    "created_at": "2023-08-31T14:04:57.124Z",
                    "updated_at": "2023-08-31T14:04:57.124Z"
                }
            ]
        },
        "purchased_option": {
            "id": 3,
            "optionable_type": "Season",
            "optionable_id": 1,
            "price": "9.99",
            "quality": "SD",
            "created_at": "2023-08-31T14:04:57.124Z",
            "updated_at": "2023-08-31T14:04:57.124Z"
        },
        "expires_at": "2023-09-02T02:04:57.096Z"
    }
]
```
