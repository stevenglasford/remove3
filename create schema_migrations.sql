CREATE TABLE schema_migrations (
    version varchar PRIMARY KEY,
    applied_at timestamp without time zone
);
