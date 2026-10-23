-- 1. List every workshop, with the most recent first.
SELECT workshop_code, workshop_title, workshop_date, location
FROM workshops ORDER BY workshop_date DESC, workshop_code;

-- 2. Count the attendees on each workshop, including workshops with none.
SELECT w.workshop_code, w.workshop_title, COUNT(s.id) AS attendee_count
FROM workshops AS w LEFT JOIN signups AS s ON s.workshop_id = w.id
GROUP BY w.id ORDER BY w.workshop_code;

-- 3. List every attendee together with the title of the workshop they signed up for, using a join.
SELECT s.id, s.first_name, s.last_name, s.email, w.workshop_title
FROM signups AS s JOIN workshops AS w ON w.id = s.workshop_id
ORDER BY w.workshop_code, s.id;

-- 4. Find every attendee whose email address is not from the au.edu domain.
SELECT s.id, s.first_name, s.last_name, s.email
FROM signups AS s WHERE lower(s.email) NOT LIKE '%@au.edu'
ORDER BY s.id;

-- 5. Find the workshop with the largest number of attendees.
SELECT w.workshop_code, w.workshop_title, COUNT(s.id) AS attendee_count
FROM workshops AS w LEFT JOIN signups AS s ON s.workshop_id = w.id
GROUP BY w.id ORDER BY attendee_count DESC, w.workshop_code LIMIT 1;

-- 6. Update one workshop's location, changing exactly one row.
UPDATE workshops SET location = 'Computer Lab C' WHERE workshop_code = 'WS101';

-- 7. Delete a single attendee by id, and show that their workshop still exists afterward.
-- Attendee id 1 belongs to WS101. The second statement verifies the parent remains.
DELETE FROM signups WHERE id = 1;
SELECT workshop_code, workshop_title FROM workshops WHERE workshop_code = 'WS101';

-- 8. Insert a new workshop with no attendees, proving the insert anomaly is gone.
INSERT INTO workshops (workshop_code, workshop_title, workshop_date, location, format, instructor, capacity)
VALUES ('WS109', 'Database Design Practice', '2026-11-21', 'Room 205', 'Hybrid', 'Prof. Ana Ruiz', 24);
SELECT w.workshop_code, w.workshop_title, COUNT(s.id) AS attendee_count
FROM workshops AS w LEFT JOIN signups AS s ON s.workshop_id = w.id
WHERE w.workshop_code = 'WS109' GROUP BY w.id;
