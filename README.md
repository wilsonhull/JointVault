# JointVault v1

A production starter package for your cloud-based team knowledge app.

## What this package includes
- Next.js app shell with professional list-based JointVault UI
- Supabase client setup
- PWA manifest and hospital icon
- Supabase SQL schema for the cloud database
- Product requirements document
- Environment variable template

## How to run locally on a computer
1. Install Node.js.
2. Unzip this folder.
3. In Terminal, run:

```bash
npm install
npm run dev
```

4. Open the local URL shown in Terminal.

## How to make it a true cloud app
1. Create a Supabase project.
2. Run `supabase/schema.sql` in Supabase SQL Editor.
3. Create a private Supabase Storage bucket named `jointvault-documents`.
4. Copy `.env.example` to `.env.local` and add your Supabase keys.
5. Push the folder to GitHub.
6. Import the GitHub repo into Vercel.
7. Add the same environment variables in Vercel.
8. Deploy.
9. Open the Vercel URL from iPhone and choose **Add to Home Screen**.

## Important security note
This app is designed for operational team knowledge. Review all uploaded notes and remove anything that should not be shared with the full team before inviting reps.

## Next development steps
- Wire real Supabase auth and admin invites
- Replace seed data with Supabase queries
- Add file upload UI using Supabase Storage
- Add edit forms for hospitals, surgeons, procedures, products, comments, favorites and version history
- Add offline pinning with service worker / local cache
