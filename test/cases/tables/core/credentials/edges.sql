ALTER TABLE core.credentials 
    ADD CONSTRAINT credentials_users_id FOREIGN KEY (user_id) REFERENCES core.users(id) ON DELETE RESTRICT;