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