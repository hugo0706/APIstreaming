# APIstreaming

## Introduction

This project simulates a RESTful API for a streaming service. The API handles various requests, including listing available movies, seasons, and the entire catalog offered by the service. It also manages user libraries and handles purchase requests.

## Asumptions

- 10 movie/seasons added every week
- Users can buy the same content in different qualities
- Cache has to be invalidated upon arrival of new content
- User library needs 100% data accuracy
- User authentication is not required, user_id can be used to identify

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
    rake db:create
    rake db:migrate
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
