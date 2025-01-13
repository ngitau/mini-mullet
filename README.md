# README

## Requirements

There is only one entity, a user, which has the following two attributes:
 - name - this is a required attribute
 - password - this is required and must be "strong"

A password is considered "strong" if all of the following conditions are met:
 - It has at least 10 characters and at most 16 characters.
 - It contains at least one lowercase character, one uppercase character and one digit.
 - It cannot contain three repeating characters in a row (e.g. "...zzz..." is not strong, but "...zz...z..." is strong, assuming other conditions are met).
   - For example, the following passwords are "strong":
     - `Aqpfk1swods`
     - `QPFJWz1343439`
     - `PFSHH78KSMa`
   - And the following passwords are not "strong":
     - `Abc123` (this is too short)
     - `abcdefghijklmnop` (this does not contain an uppercase character or a digit)
     - `AAAfk1swods` (this contains three repeating characters, namely AAA)

When I visit the homepage of the website, I can upload a CSV file of names and passwords (this is all that I can do when I visit the homepage).
After uploading the CSV file, I see the results of the uploaded CSV.

For each row in the CSV file, the system will attempt to create a User in the database and display the result of each row on the website:
 - If a row leads to a valid User, then the User is saved and the result for this row is a success.
 - If a row leads to an invalid User, the User should not be saved and an error should be shown in the results on the website.


You do not need to make the website look pretty. You must use Stimulus to trigger the form submission. Do not implement any additional functionality, such as user authentication.

## Demo URL
[ Visit Demo ](https://dais.ndungugitau.com)

## Assumptions
- A valid csv will have a header row
- CSV columns that have a comma will be quoted with _double quotes
- A user can only upload a file on the page
- The app should only have one DB entity, user
- A `User` record is not unique by name and password
- Upload results cannot be displayed again if the user refreshes the page or navigates away from it

## Run Tests
```shell
  ./bin/rails spec
```

