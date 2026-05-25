# frontend

A new Flutter project.

## Fix Firebase Storage CORS (Flutter Web)

If you run the app on web (`flutter run -d chrome`) and image uploads fail with a browser error like:

`blocked by CORS policy` / `Response to preflight request doesn't pass access control check`

you need to add a CORS policy to your Firebase Storage bucket.

0) Ensure Firebase **Storage** is enabled for the project (this creates the bucket).

- Firebase Console  Storage  **Get started**  choose a location  finish setup

If Storage isn't enabled yet, uploads can fail with CORS-like browser errors because the bucket URL returns a non-200 response (preflight fails).

1) Run the web app on a stable port (so the origin doesn't change):

`flutter run -d chrome --web-port=5000`

2) Install Google Cloud SDK (includes `gsutil`) and sign in:

- https://cloud.google.com/sdk/docs/install
- Then: `gcloud auth login`

3) Apply the CORS config in [storage_cors.json](storage_cors.json) to your bucket:

`gsutil cors set storage_cors.json gs://matcha-recipes.firebasestorage.app`

If your bucket name is different, copy it from Firebase Console  Storage (the bucket name is shown at the top of the page).

Changes can take a minute to propagate; restart the web app after applying.

## Use Supabase Storage for Images (Production-Friendly Alternative)

If you don't want to use Firebase Storage for images, you can upload images to **Supabase Storage** and continue using **Firestore** for recipe metadata (including the `imageUrl`).

### Supabase setup

1) Create a Supabase project
2) Storage  create a bucket (recommended name: `recipes`)
3) Decide access:

- **Simplest:** make the bucket public (images can be viewed by anyone with the URL)
- **More secure:** keep it private and use signed URLs (not implemented yet; ask if you want this)

### Run the app with Supabase enabled

Provide these values via `--dart-define` so secrets are not committed to git:

Windows PowerShell (recommended on Windows):

```powershell
flutter run -d chrome --web-port=5000 `
	--dart-define=USE_SUPABASE=true `
	--dart-define=USE_SUPABASE_STORAGE=true `
	--dart-define=SUPABASE_URL=YOUR_SUPABASE_URL `
	--dart-define=SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY `
	--dart-define=SUPABASE_STORAGE_BUCKET=recipes
```

Or as a single line:

```powershell
flutter run -d chrome --web-port=5000 --dart-define=USE_SUPABASE=true --dart-define=USE_SUPABASE_STORAGE=true --dart-define=SUPABASE_URL=YOUR_SUPABASE_URL --dart-define=SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY --dart-define=SUPABASE_STORAGE_BUCKET=recipes
```

### Convenience: use a local .env file (PowerShell)

1) Copy `.env.example` to `.env` and fill in your real values.
2) Run the helper script:

```powershell
.\tools\run_with_env.ps1
```

Optional parameters:

```powershell
.\tools\run_with_env.ps1 -Device chrome -WebPort 5000
```

Where to find values:

- Supabase Dashboard  Project Settings  API
	- `SUPABASE_URL` = Project URL (recommended: `https://<ref>.supabase.co`).
		If you copy the REST URL like `https://<ref>.supabase.co/rest/v1/`, that's OK too.
	- `SUPABASE_ANON_KEY` = anon/public **JWT** key (usually starts with `eyJ...`).
		Do not use keys that start with `sb_publishable_...` here (Storage will fail with "Invalid Compact JWS").

### Required Storage policy (uploads)

Even if the bucket is public, **uploads** require an INSERT policy on `storage.objects`.

Supabase Dashboard  Storage  Policies  New policy:

- Table: `storage.objects`
- Operation: `INSERT`
- Roles: `anon` (and `authenticated` if you use Supabase Auth)
- Condition / check:
	- `bucket_id = 'recipes'`

If `USE_SUPABASE_STORAGE` is not set to true, the app will use Firebase Storage (current default).

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
