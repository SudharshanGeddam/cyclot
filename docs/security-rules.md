# Firebase Security Rules & Indexes

Cyclot enforces strict data access controls using Firebase Security Rules. 

## Firestore Security Rules

To apply these rules, copy the following into your Firebase Console (Build > Firestore Database > Rules) or deploy via Firebase CLI using `firebase deploy --only firestore:rules`.

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
  
    // Reusable function to check authentication
    function isAuthenticated() {
      return request.auth != null;
    }

    // Reusable functions to check roles
    // NOTE: In a production environment, roles should be securely verified via Custom Claims.
    // For this prototype, we check the user document.
    function getUserRole() {
      return get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role;
    }
    
    function isAdmin() {
      return isAuthenticated() && getUserRole() == 'admin';
    }
    
    function isSecurity() {
      return isAuthenticated() && getUserRole() == 'security';
    }
    
    function isEmployee() {
      return isAuthenticated() && getUserRole() == 'employee';
    }

    // 1. Users Collection
    match /users/{userId} {
      // Anyone authenticated can read their own profile. Admins and security can read all.
      allow read: if isAuthenticated() && (request.auth.uid == userId || isAdmin() || isSecurity());
      // Employees can only be created during registration. Admins can update.
      allow create: if isAuthenticated() && request.auth.uid == userId;
      allow update, delete: if isAdmin();
    }

    // 2. Bikes Collection
    match /bikes/{bikeId} {
      // All authenticated users can view bikes.
      allow read: if isAuthenticated();
      // Only Security and Admin can add/remove/update bikes directly (unless via allocation transaction)
      allow write: if isSecurity() || isAdmin() || isEmployee(); 
      // Note: In strict production, employee writes should be restricted only to allocation fields 
      // via fine-grained field-level rules.
    }

    // 3. Allocations Collection
    match /allocations/{allocationId} {
      // Employees can read their own allocations. Security/Admins can read all.
      allow read: if isAuthenticated() && (request.resource.data.employeeId == request.auth.uid || isSecurity() || isAdmin());
      // Employees can create an allocation and update it to 'returned'
      allow create: if isEmployee() && request.resource.data.employeeId == request.auth.uid;
      allow update: if (isEmployee() && resource.data.employeeId == request.auth.uid) || isSecurity() || isAdmin();
      allow delete: if isAdmin();
    }

    // 4. Notifications Collection
    match /notifications/{notificationId} {
      // Employees can only read and update their own notifications (e.g. mark as read).
      allow read, update: if isAuthenticated() && resource.data.employeeId == request.auth.uid;
      // Security and Admins can create notifications.
      allow create: if isSecurity() || isAdmin();
      allow delete: if isAdmin();
    }
  }
}
```

## Required Indexes

Firestore requires composite indexes for complex queries (e.g. querying active allocations). You will be prompted with a direct link in the debug console if an index is missing, or you can deploy the following `firestore.indexes.json` using the Firebase CLI:

```json
{
  "indexes": [
    {
      "collectionGroup": "allocations",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "employeeId",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "status",
          "order": "ASCENDING"
        }
      ]
    },
    {
      "collectionGroup": "bikes",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "isAllocated",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "isDamaged",
          "order": "ASCENDING"
        }
      ]
    }
  ],
  "fieldOverrides": []
}
```
