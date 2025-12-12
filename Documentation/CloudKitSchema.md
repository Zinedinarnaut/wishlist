# CloudKit Schema

## Containers
- Default iCloud container (Private database)

## Record Types
### User
- **Record Name**: Apple `userIdentifier`
- **Fields**
  - `createdAt` (Date)

### WishlistBoard (Record Type: `WishlistBoard`)
- **Fields**
  - `name` (String)
  - `userId` (String) — Apple `userIdentifier` for scoping
  - `createdAt` (Date)

### WishlistItem (Record Type: `WishlistItem`)
- **Fields**
  - `boardId` (Reference -> WishlistBoard, deleteSelf)
  - `title` (String)
  - `brand` (String, Optional)
  - `price` (Decimal, Optional)
  - `currency` (String, Optional)
  - `imageURL` (String, Optional)
  - `productURL` (String)
  - `metadata` (Dictionary<String, String>)
  - `notes` (String)
  - `createdAt` (Date)
  - `order` (Int)

## Security & Queries
- All operations use the **Private Database** to stay user-scoped by default.
- `WishlistBoard` queries filter on `userId` to enforce ownership.
- `WishlistItem` queries use `boardId` references scoped to boards the user owns.
