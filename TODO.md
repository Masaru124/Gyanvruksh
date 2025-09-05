# TODO for Gyan Coins System, Leaderboard, Profile Updates, and Educonnect Replacement

## Backend
- [ ] Add `gyan_coins` integer field to `User` model in `backend/app/models/user.py`.
- [ ] Add logic to calculate and update gyan coins based on course hours completed (1 coin per 10 hours).
- [ ] Create new API endpoints:
  - [ ] GET `/api/gyanvruksh/leaderboard` - returns top students by gyan coins.
  - [ ] GET `/api/gyanvruksh/profile` - returns user profile including gyan coins.
- [ ] Update existing user profile API if needed to include gyan coins.

## Frontend (Flutter)
- [ ] Update `profile_screen.dart` to display gyan coins.
- [ ] Create new `leaderboard_screen.dart` to show leaderboard of students by gyan coins.
- [ ] Add API calls in `api.dart` for leaderboard and profile updates.
- [ ] Replace all occurrences of "educonnect" with "Gyanvruksh" in UI strings and code files.
- [ ] Follow existing style patterns for UI consistency.

## Testing
- [ ] Test backend API endpoints for correctness.
- [ ] Test frontend profile screen updates.
- [ ] Test leaderboard screen functionality.
- [ ] Verify all "educonnect" replaced with "Gyanvruksh" in UI and code.

## Deployment
- [ ] Ensure migrations are created and applied for new DB fields.
- [ ] Build and deploy updated mobile app.
