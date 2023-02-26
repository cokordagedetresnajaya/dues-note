# Dues Note

Dues Note is a mobile apps for recording organization or community member fees and transactions. This project created with flutter, Firebase Realtime Database for the database, and Provider to manage the app state.

## Getting Started

#### 1. Clone the repo
```sh
git clone https://github.com/cokordagedetresnajaya/dues-note.git
cd dues-note
```
#### 2. Install the packages
```sh
flutter pub get
```
#### 3. Setup Firebase Realtime Database and Firebase Authentication
#### a.  Create Firebase Project
To create new Firebase Project, you can create it <a target="_blank" href="https://console.firebase.google.com">here</a>
#### b.  Set Firebase Authentication
Select Email/Password
<p>
  <img src="https://user-images.githubusercontent.com/90399814/221390659-5b28ee85-8c10-4598-a0e4-d8a46c360be5.png" alt="feed example" width="700">
</p>

Set Email/Password to enable and save change

<p>
  <img src="https://user-images.githubusercontent.com/90399814/221390818-b4b9b406-2330-4d09-9644-ed9e1b9e3633.png" alt="feed example" width="700">
</p>

#### c.  Set Firebase Realtime Database
* Create Realtime Database
* Copy Realtime Database Host Name and set firebaseBaseUrl with Realtime Database Host Name in lib/configs/core.dart

<p>
  <img src="https://user-images.githubusercontent.com/90399814/221393340-5cc35f36-a051-421b-89fa-33ca3b9e69f7.png" alt="feed example" width="700">
</p>

* Set Realtime Database Rules

Copy this rules to Realtime Database Rules
```sh
{
  "rules": {
    ".read": "auth != null",
    ".write": "auth != null",
    "organizations": {
      ".indexOn": ["userId"]
    },
    "transactions": {
      ".indexOn": ["organizationId"]
    },
    "organization_fees": {
      ".indexOn": ["organizationId"]
    },
    "members": {
      ".indexOn": ["duesId"]
    }
  }
}
```

#### 4. Set API Key
Copy web api key in Project Settings to apiKey in lib/configs/core.dart

<p>
  <img src="https://user-images.githubusercontent.com/90399814/221393994-805cc64e-c946-4144-b929-d7c6221ba1a9.png" alt="feed example" width="700">
</p>


