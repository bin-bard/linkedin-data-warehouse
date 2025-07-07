SELECT
    DATEADD(SECOND, MIN(original_listed_time) / 10000, '1970-01-01') AS MinOriginalListedTime,
    DATEADD(SECOND, MAX(original_listed_time) / 10000, '1970-01-01') AS MaxOriginalListedTime,
    DATEADD(SECOND, MIN(listed_time) / 10000, '1970-01-01') AS MinListedTime,
    DATEADD(SECOND, MAX(listed_time) / 10000, '1970-01-01') AS MaxListedTime,
    DATEADD(SECOND, MIN(expiry) / 10000, '1970-01-01') AS MinExpiry,
    DATEADD(SECOND, MAX(expiry) / 10000, '1970-01-01') AS MaxExpiry,
    DATEADD(SECOND, MIN(closed_time) / 10000, '1970-01-01') AS MinClosedTime,
    DATEADD(SECOND, MAX(closed_time) / 10000, '1970-01-01') AS MaxClosedTime
FROM postings;
