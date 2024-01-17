CREATE OR REPLACE FUNCTION update_guard() RETURNS TRIGGER AS $$
    DECLARE 
        t TIMESTAMP;
    BEGIN
        IF OLD.verified = TRUE THEN
            NEW.verified = TRUE; 
        END IF;
        IF NEW.deletion_date IS NULL THEN
                IF OLD.deletion_date IS NULL THEN
                    NEW.creation_date = OLD.creation_date;
                    NEW.modification_date = CURRENT_TIMESTAMP;
                    NEW.version = OLD.version + 1;
                ELSE 
                    NEW = OLD;
                    NEW.deletion_date = null;
                END IF;
        ELSE 
            t := NEW.deletion_date;
            NEW = OLD;
            NEW.deletion_date = t;
        END IF;
        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;