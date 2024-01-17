CREATE TRIGGER core_users_before_insert BEFORE INSERT ON core.users FOR EACH ROW EXECUTE FUNCTION insert_guard();
CREATE TRIGGER core_users_before_update BEFORE UPDATE ON core.users FOR EACH ROW EXECUTE FUNCTION update_guard();

CREATE TRIGGER core_user_notify_insert AFTER INSERT ON core.users FOR EACH ROW EXECUTE FUNCTION notify_user_creation();