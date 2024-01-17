CREATE FUNCTION insert_credential() RETURNS TRIGGER AS $$
    BEGIN
        NEW.password = crypt(NEW.password, gen_salt('bf'));
        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;