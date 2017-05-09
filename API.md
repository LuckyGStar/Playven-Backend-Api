# Playven API Documentation 

This page includes our API documentation and styleguide on how to write your API documentation. 

Please pay attention to how you write it as it will be vital for others working to clearly understand how it works. 
Especially in cases where the other developer might be a Front End person with no knowledge or our backend.

## Table of Contents
  1. [Style Guide](#style-guide)
  1. [Authentication](#authentication)
    1. [Login API](#login-api)
    1. [Register API](#register-api)
    1. [Update Profile API](#update-profile-api)
    1. [Reset Password API](#reset-password-api)
    1. [Confirm Account API](#confirm-account-api)
    1. [Email Check API](#email-check-api)

# Style Guide

When creating API Documentation for your API Endpoint it should include the following things:

* URL for the Endpoint
* Method of Endpoint (POST/PUT/GET/DELETE)/PATCH)
* Request Body
* Success Response
* Error Response including status code and content and causes for these

Abiding these simple rules will keep our API Documentation clean and easy to use for everyone. 

Yay!

# Authentication

Listed below are Authentication related API endpoints

# Login API
  Returns json data.

* **URL**

  /api/authenticate?email={email_ID}&password={UserPassword}

* **Method:**

  `POST`

* **Success Response:**

  * **Code:** 200 <br />
    **Content:** `{ auth_token: "ENCODED_AUTH_TOKEN" }`

* **Error Response:**

  If username or password are incorrect:

  * **Code:** 403 UNAUTHORIZED <br />
    **Content:** `{ error : 'Invalid username or password' }`

  OR

  If user is not confirmed and password is blank:

  * **Code:** 422 <br />
    **Content:** `{ error: 'unconfirmed_account', message: 'User is already created but not confirmed' }`


# Register API
  Returns json data.

* **URL**

  /api/users

* **Method:**

  `POST`

*  **Request Body**

```
{
  "user": {
    "email": "allama.iqbal@gmail.com",
    "password": "SECRET_KEY",
    "password_confirmation": "SECRET_KEY",
    "first_name": "Allama",
    "last_name": "Iqbal",
    "phone_number": "00923366521421",
    "street_address": "15",
    "zipcode": 56000,
    "city": "Islamabad"
  }
}
```

* **Success Response:**

  * **Code:** 200 <br />
    **Content:** `{ auth_token: "ENCODED_AUTH_TOKEN" }`

* **Error Response:**

  If user is not confirmed and password is blank:

  * **Code:** 422 <br />
    **Content:** `{ error: 'unconfirmed_account', message: 'User is already created but not confirmed' }`

  OR

  If user is not confirmed and password is present:

  * **Code:** 422 <br />
    **Content:** `{ error: 'already_exists', message: 'Email already exists' }`


# Update Profile API
  Returns json data.

* **URL**

  /api/users/{user_id}

* **Method:**

  `PUT`

*  **Request Body**

  ```
  { "user":
    {"email": "test@gmail.com",
    "first_name": "Test1",
    "last_name": "Test1",
    "phone_number": "00923366521421",
    "street_address": "15",
    "zipcode": 56000,
    "city": "Lahore" }
  }
  ```

* **Success Response:**

  if password and current_password are provided in the request body:

  * **Code:** 200 <br />
    **Content:** `{ message: "Password updated successfully" }`

  OR

  if password and current_password are not provided in the request body:

  * **Code:** 200 <br />
    **Content:** `{ message: "User profile updated successfully" }`

* **Error Response:**

  if `current_password` is incorrect:

  * **Code:** 422 <br />
    **Content:** `{ error : "Current password is not valid" }`

  if `password` length is short:

  * **Code:** 422 <br />
    **Content:** `{ error : "Password is too short" }`

  OR

  * **Code:** 401 UNAUTHORIZED <br />
    **Content:** `{ error : "You are not currently logged in." }`


# Reset Password API
Returns json data.

* **URL**

  /api/users/reset_password?email={email_ID}

* **Method:**

  `POST`

* **Success Response:**

  * **Code:** 200 <br />
    **Content:** `{ message: "Reset password email sent successfully" }`

* **Error Response:**

  * **Code:** 404 <br />
    **Content:** `{ error : user.errors.full_messages.join(', ') }`


# Confirm Account API
Returns json data.

* **URL**

  /api/users/confirm_account

* **Method:**

  `POST`

*  **Request Body**

```
{
  "user": {
    "email": "test@test.com"
  }
}
```

* **Success Response:**

  * **Code:** 200 <br />
    **Content:** `{ message: "Confirmation email sent successfully" }`

* **Error Response:**

  * **Code:** 422 <br />
    **Content:** `{ error : "Email parameter is required" }`

  OR

  * **Code:** 422 <br />
    **Content:** `{ error : "Confirmation email could not be sent" }`

# Email Check API

End point for Mobile Devices in Login to check if there is an user with given email address. Returns a json message.

## URL

``` 
  /api/users/email_check 
```

## Method

`GET`

## Request Body
```
  {
    "email": "check@email.com"
  }
```

## Success Response

* Code 200
* Content `{ message: "Account found with given email" }`

## Error Response

With an invalid email param or no user account found

* Code 422
* Content `{ message: "No account found with given email" }`

With no email given

* Code 422
* Content `{ message: "Email parameter is required" }`