# UniPath Backend

This is a professional Django REST API backend for the UniPath Flutter application.

## Features

- **PostgreSQL Database**: Using Neon PostgreSQL for production-ready database
- **JWT Authentication**: Secure token-based authentication with refresh tokens
- **User Management**: Custom user profiles with student information
- **API Versioning**: Versioned API endpoints (v1)
- **Filtering & Search**: Advanced filtering and search capabilities
- **Rate Limiting**: Built-in throttling for API protection
- **CORS Support**: Cross-origin resource sharing for web clients
- **Permissions**: Object-level permissions with Django Guardian
- **Pagination**: Efficient pagination for large datasets

## Setup

1. Create a virtual environment:
   ```bash
   python -m venv venv
   ```

2. Activate the virtual environment:
   - Windows: `venv\Scripts\activate`
   - Linux/Mac: `source venv/bin/activate`

3. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

4. Run migrations:
   ```bash
   python manage.py migrate
   ```

5. Create a superuser:
   ```bash
   python manage.py createsuperuser
   ```

6. Run the server:
   ```bash
   python manage.py runserver
   ```

## API Endpoints

### Authentication
- `POST /api/v1/auth/register/` - User registration
- `POST /api/v1/auth/login/` - User login (JWT tokens)
- `POST /api/v1/auth/token/refresh/` - Refresh access token
- `POST /api/v1/auth/token/verify/` - Verify token
- `GET/PUT/PATCH /api/v1/auth/profile/` - User profile management

### Courses
- `GET/POST /api/v1/courses/courses/` - List/Create courses
- `GET/PUT/PATCH/DELETE /api/v1/courses/courses/{id}/` - Course detail
- `GET/POST /api/v1/courses/sections/` - List/Create sections
- `GET/PUT/PATCH/DELETE /api/v1/courses/sections/{id}/` - Section detail
- `GET/POST /api/v1/courses/section-times/` - List/Create section times
- `GET/PUT/PATCH/DELETE /api/v1/courses/section-times/{id}/` - Section time detail

### Admin
- `/admin/` - Django admin interface

## Authentication

The API uses JWT (JSON Web Tokens) for authentication. Include the access token in the Authorization header:

```
Authorization: Bearer <access_token>
```

## Filtering & Search

### Courses
- Filter by units: `?units=3`
- Search by name: `?search=math`
- Order by: `?ordering=name` or `?ordering=-units`

### Sections
- Filter by course: `?course=1`
- Filter by instructor: `?instructor=John`
- Search: `?search=calculus`
- Order by: `?ordering=section_number`

### Section Times
- Filter by day: `?day=mon`
- Filter by course: `?section__course=1`
- Search by location: `?search=room101`
- Order by: `?ordering=day,start_time`

## Security Features

- JWT authentication with token refresh
- Rate limiting (100/hour for anonymous, 1000/hour for authenticated users)
- CORS protection
- Object-level permissions
- Password validation
- Token blacklisting on logout
