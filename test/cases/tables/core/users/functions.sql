CREATE OR REPLACE FUNCTION notify_user_creation() RETURNS TRIGGER AS $$
    BEGIN
        EXECUTE format('notify users, ''{"email": "%s", "verification_hash": "%s"}''', NEW.email, NEW.verification_hash);     
        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;