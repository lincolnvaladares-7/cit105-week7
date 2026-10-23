-- CIT 105 Module 7: normalized workshop registration database
PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS workshops (
    id INTEGER PRIMARY KEY,
    workshop_code TEXT NOT NULL UNIQUE, -- A workshop code identifies exactly one workshop.
    workshop_title TEXT NOT NULL,
    workshop_date TEXT NOT NULL,
    location TEXT NOT NULL,
    format TEXT NOT NULL CHECK (format IN ('In-person', 'Online', 'Hybrid')),
    instructor TEXT NOT NULL,
    capacity INTEGER NOT NULL CHECK (capacity > 0)
);

CREATE TABLE IF NOT EXISTS signups (
    id INTEGER PRIMARY KEY,
    workshop_id INTEGER NOT NULL,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    email TEXT NOT NULL CHECK (length(trim(email)) > 0),
    role TEXT NOT NULL CHECK (role IN ('Student', 'Staff', 'Faculty', 'Guest', 'Visitor')),
    signup_date TEXT NOT NULL,
    -- One email may register for many workshops, but only once per workshop.
    UNIQUE (workshop_id, email),
    FOREIGN KEY (workshop_id) REFERENCES workshops(id)
);
