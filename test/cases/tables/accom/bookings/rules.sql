CREATE RULE accom_booking_delete_protect AS ON DELETE TO accom.bookings DO INSTEAD NOTHING;
CREATE RULE accom_booking_update_protect AS ON UPDATE TO accom.bookings DO INSTEAD NOTHING;