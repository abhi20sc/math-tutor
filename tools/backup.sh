#!/usr/bin/env bash
# A backup you can actually hold, for the Free plan.
#
#     tools/backup.sh                       # to ~/astro-backups
#     tools/backup.sh /Volumes/Backup       # somewhere else
#
# WHY THIS EXISTS
#
# Supabase's Free plan takes daily backups but does not let you download
# them. So the honest recovery story on Free is "ask Supabase and hope",
# and for a database holding children's practice history that is not a
# story at all. This gives you a file.
#
# WHERE THE DUMP MUST NOT GO
#
# Not into this repository — it is public. Not into a GitHub Actions
# artifact, not into a cloud drive that syncs to shared folders. It is real
# students' work: names, email addresses, every answer they gave. Keep it on
# a disk you control, and delete old ones when they stop being useful.
#
# The repository ignores *.sql.gz and the default output directory for this
# reason, but the safest habit is keeping it outside the repo entirely,
# which is why the default is your home directory.
set -euo pipefail

OUT="${1:-$HOME/astro-backups}"
STAMP=$(date +%Y-%m-%d-%H%M)
FILE="$OUT/astro-$STAMP.sql.gz"

if [ -z "${SUPABASE_DB_URL:-}" ]; then
  cat >&2 <<'MSG'
SUPABASE_DB_URL is not set.

  Dashboard -> Project Settings -> Database -> Connection string -> URI,
  then use the SESSION POOLER string (port 5432). The direct connection is
  IPv6-only and fails on most home networks.

  export SUPABASE_DB_URL='postgresql://postgres.PROJECT:PASSWORD@HOST:5432/postgres'

Do not paste that into a file in this repository. It is public, and the
password in it is full write access to every student's record.
MSG
  exit 1
fi

command -v pg_dump >/dev/null || {
  echo "pg_dump not found.  brew install libpq  (then add it to PATH)" >&2
  exit 1
}

mkdir -p "$OUT"
chmod 700 "$OUT"

echo "  dumping to $FILE"
# --no-owner and --no-acl so the dump restores into a fresh project without
# fighting over roles that will not exist there.
pg_dump "$SUPABASE_DB_URL" \
  --no-owner --no-acl \
  --schema=public --schema=auth \
  | gzip -9 > "$FILE"

chmod 600 "$FILE"
SIZE=$(du -h "$FILE" | cut -f1)

# A dump that cannot be read is not a backup. Check the gzip stream and look
# for a table that must be there, rather than trusting the exit code.
gzip -t "$FILE"
if ! gzip -dc "$FILE" | grep -q 'CREATE TABLE public.profiles'; then
  echo "  ! the dump is missing public.profiles - do not trust it" >&2
  exit 1
fi

echo "  $SIZE, verified readable and contains public.profiles"
echo
echo "  To restore into a fresh project:"
echo "    gzip -dc $FILE | psql \"\$NEW_DB_URL\""
