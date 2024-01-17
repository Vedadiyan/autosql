CREATE RULE core_credentials_delete_protect AS ON DELETE TO core.credentials DO INSTEAD NOTHING;
CREATE RULE core_credentials_update_protect AS ON UPDATE TO core.credentials DO INSTEAD NOTHING;