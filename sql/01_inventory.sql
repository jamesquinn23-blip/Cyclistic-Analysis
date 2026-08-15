--- Confirm that DuckDB is connected to the intended project database.

PRAGMA database_list;

--- Inventory the extracted monthly CSV files.
--- Expect 12 CSVs dating from July 2025 to June 2026

SELECT *
FROM glob('data/*.csv')
ORDER BY file;