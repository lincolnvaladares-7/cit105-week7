"""Load workshop_signups.csv into a normalized SQLite database."""
import argparse
import csv
import logging
import sqlite3
from pathlib import Path

ROOT = Path(__file__).resolve().parent
WORKSHOP_FIELDS = ('workshop_title', 'workshop_date', 'location', 'format', 'instructor', 'capacity')


def load(csv_path: Path, db_path: Path) -> None:
    logging.basicConfig(level=logging.INFO, format='%(levelname)s: %(message)s')
    conn = sqlite3.connect(db_path)
    conn.execute('PRAGMA foreign_keys = ON')
    inserted = rejected = 0
    try:
        conn.executescript((ROOT / 'schema.sql').read_text(encoding='utf-8'))
        with csv_path.open(newline='', encoding='utf-8-sig') as stream:
            for line_no, row in enumerate(csv.DictReader(stream), start=2):
                try:
                    with conn:
                        code = row['workshop_code'].strip()
                        workshop_values = [row[key].strip() for key in WORKSHOP_FIELDS]
                        if not code or any(not value for value in workshop_values):
                            raise ValueError('missing required workshop field')
                        workshop_values[-1] = int(workshop_values[-1])
                        conn.execute('''INSERT OR IGNORE INTO workshops
                            (workshop_code, workshop_title, workshop_date, location, format, instructor, capacity)
                            VALUES (?, ?, ?, ?, ?, ?, ?)''', (code, *workshop_values))
                        parent = conn.execute('SELECT id, workshop_title, workshop_date, location, format, instructor, capacity FROM workshops WHERE workshop_code = ?', (code,)).fetchone()
                        if parent is None or tuple(parent[1:]) != tuple(workshop_values):
                            raise ValueError('conflicting workshop information')
                        fields = [row[key].strip() for key in ('first_name', 'last_name', 'email', 'role', 'signup_date')]
                        if not any(fields):
                            logging.info('CSV line %d: workshop %s has no attendees', line_no, code)
                            continue
                        if any(not value for value in fields):
                            raise ValueError('incomplete attendee record')
                        conn.execute('''INSERT INTO signups
                            (workshop_id, first_name, last_name, email, role, signup_date)
                            VALUES (?, ?, ?, ?, ?, ?)''', (parent[0], *fields))
                        inserted += 1
                except (ValueError, sqlite3.IntegrityError) as exc:
                    rejected += 1
                    logging.warning('Rejected CSV line %d (%s): %s', line_no, row.get('workshop_code'), exc)
        logging.info('Imported %d attendees; rejected %d rows', inserted, rejected)
        logging.info('Workshops: %d', conn.execute('SELECT COUNT(*) FROM workshops').fetchone()[0])
    finally:
        conn.close()


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--csv', type=Path, default=ROOT / 'workshop_signups.csv')
    parser.add_argument('--db', type=Path, default=ROOT / 'workshops.db')
    args = parser.parse_args()
    load(args.csv, args.db)
