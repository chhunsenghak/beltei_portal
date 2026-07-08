supabase db reset
docker restart supabase_kong_beltei_portal
Push-Location supabase/seeder
dart pub get
dart run seed.dart
Pop-Location
