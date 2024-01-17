CREATE OR REPLACE FUNCTION insert_guard() RETURNS TRIGGER AS $$
    BEGIN
        NEW.deletion_date = null;
        NEW.creation_date = CURRENT_TIMESTAMP;
        NEW.modification_date = CURRENT_TIMESTAMP;
        NEW.version = 1;
        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;