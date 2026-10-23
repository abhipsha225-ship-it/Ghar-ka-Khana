# Security Considerations

## Admin Account Provisioning
`main.dart` contains a hard-coded attempt to create an admin account using a fixed email and password. Remove this bootstrap credential from production code and use a secure admin provisioning process.

## Firebase Security
Firebase client configuration does not replace Firestore Security Rules. Configure rules to enforce authorization and restrict access to data based on user roles and permissions.

## Database Seeding
Never run the destructive `seed_db.dart` process against production data.
