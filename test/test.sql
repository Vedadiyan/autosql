CREATE TABLE IF NO EXISTS accom.bookings(
    id BIGINT PRIMARY NOT NULL GENERATED ALWAYS AS IDENTITY,
    user_id BIGINT NOT NULL,
    "provider" VARCHAR(100) NOT NULL,
    "hash" VARCHAR(64) NOT NULL,
    "reference" UUID NOT NULL,
    creation_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
)
CREATE TABLE IF NOT EXISTS core.credentials (
    id BIGINT GENERATED ALWAYS AS IDENTITY,
    user_id BIGINT NOT NULL,
    "password" VARCHAR(64) NOT NULL,
    creation_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS core.users (
    id BIGINT PRIMARY KEY NOT NULL GENERATED ALWAYS AS IDENTITY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    phone VARCHAR(25) NOT NULL UNIQUE,
    verified BOOLEAN NOT NULL,
    verification_hash VARCHAR(64) NOT NULL,
    creation_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modification_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deletion_date TIMESTAMP NULL,
    "version" INTEGER NOT NULL CHECK("version" > 0)
);
ALTER TABLE core.credentials 
    ADD CONSTRAINT credentials_users_id FOREIGN KEY (user_id) REFERENCES core.users(id) ON DELETE RESTRICT;
CREATE OR REPLACE FUNCTION insert_guard() RETURNS TRIGGER AS $$
    BEGIN
        NEW.deletion_date = null;
        NEW.creation_date = CURRENT_TIMESTAMP;
        NEW.modification_date = CURRENT_TIMESTAMP;
        NEW.version = 1;
        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;
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
CREATE FUNCTION insert_credential() RETURNS TRIGGER AS $$
    BEGIN
        NEW.password = crypt(NEW.password, gen_salt('bf'));
        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;
CREATE FUNCTION validate_login(_email CHAR(150), _password TEXT) RETURNS BOOLEAN AS $$
    BEGIN
        RETURN EXISTS (
            WITH _users AS(
                SELECT id FROM core.users WHERE email = _email AND deletion_date IS NULL
            )
            SELECT 1 FROM core.credentials JOIN _users ON core.credentials.user_id = _users.id WHERE core.credentials.password = crypt(_password, credentials.password) 
        );
    END;
$$ LANGUAGE plpgsql;
CREATE OR REPLACE FUNCTION notify_user_creation() RETURNS TRIGGER AS $$
    BEGIN
        EXECUTE format('notify users, ''{"email": "%s", "verification_hash": "%s"}''', NEW.email, NEW.verification_hash);     
        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER core_credentials_before_insert BEFORE INSERT ON core.credentials FOR EACH ROW EXECUTE FUNCTION insert_credential();
CREATE TRIGGER core_users_before_insert BEFORE INSERT ON core.users FOR EACH ROW EXECUTE FUNCTION insert_guard();
CREATE TRIGGER core_users_before_update BEFORE UPDATE ON core.users FOR EACH ROW EXECUTE FUNCTION update_guard();
CREATE TRIGGER core_user_notify_insert AFTER INSERT ON core.users FOR EACH ROW EXECUTE FUNCTION notify_user_creation();
CREATE RULE accom_booking_delete_protect AS ON DELETE TO accom.bookings DO INSTEAD NOTHING;
CREATE RULE accom_booking_update_protect AS ON UPDATE TO accom.bookings DO INSTEAD NOTHING;
CREATE RULE core_credentials_delete_protect AS ON DELETE TO core.credentials DO INSTEAD NOTHING;
CREATE RULE core_credentials_update_protect AS ON UPDATE TO core.credentials DO INSTEAD NOTHING;
CREATE RULE core_users_delete_protect AS ON DELETE TO core.users DO INSTEAD UPDATE core.users SET deletion_date = CURRENT_TIMESTAMP WHERE id = OLD.id;