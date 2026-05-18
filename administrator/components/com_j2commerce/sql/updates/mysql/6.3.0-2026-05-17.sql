-- Issue #1056 — Saved Files Management
-- Extends #__j2commerce_uploads to track order-file lifecycle:
--   pending  -> file in files/com_j2commerce/tmp/{cart_id}/
--   attached -> file in files/com_j2commerce/orders/{order_id}/
--   orphaned -> tmp upload past expires_on, awaiting cleanup
--   deleted  -> file removed, row kept for audit (when delete_db_rows=0)

ALTER TABLE `#__j2commerce_uploads`
    ADD COLUMN `order_id`    varchar(255) NOT NULL DEFAULT ''                                                    AFTER `mangled_name`,
    ADD COLUMN `cart_id`     int unsigned NOT NULL DEFAULT 0                                                     AFTER `order_id`,
    ADD COLUMN `status`      enum('pending','attached','orphaned','deleted') NOT NULL DEFAULT 'pending'           AFTER `cart_id`,
    ADD COLUMN `file_size`   bigint       NOT NULL DEFAULT 0                                                     AFTER `mime_type`,
    ADD COLUMN `expires_on`  datetime     NULL DEFAULT NULL                                                      AFTER `created_on`,
    ADD COLUMN `modified_on` datetime     NULL DEFAULT NULL                                                      AFTER `expires_on`,
    ADD INDEX `idx_order_id`   (`order_id`),
    ADD INDEX `idx_cart_id`    (`cart_id`),
    ADD INDEX `idx_status`     (`status`),
    ADD INDEX `idx_expires_on` (`expires_on`);
