INSERT IGNORE INTO `permissions_categories` (`name`) VALUES ('account_entries');
INSERT IGNORE INTO `permissions_categories` (`name`) VALUES ('account_entries_product_dimensions');
INSERT IGNORE INTO `permissions_categories` (`name`) VALUES ('account_entries_user_dimensions');
INSERT IGNORE INTO `permissions_categories` (`name`) VALUES ('accounts');
INSERT IGNORE INTO `permissions_categories` (`name`) VALUES ('api_keys');
INSERT IGNORE INTO `permissions_categories` (`name`) VALUES ('event_log');
INSERT IGNORE INTO `permissions_categories` (`name`) VALUES ('permissions');
INSERT IGNORE INTO `permissions_categories` (`name`) VALUES ('permissions_categories');
INSERT IGNORE INTO `permissions_categories` (`name`) VALUES ('products');
INSERT IGNORE INTO `permissions_categories` (`name`) VALUES ('users');
INSERT IGNORE INTO `permissions_categories` (`name`) VALUES ('users_permissions');

INSERT INTO `permissions` (`name`, `permission_category_id`) SELECT 'create', `id` FROM `permissions_categories`;
INSERT INTO `permissions` (`name`, `permission_category_id`) SELECT 'read', `id` FROM `permissions_categories`;
INSERT INTO `permissions` (`name`, `permission_category_id`) SELECT 'update', `id` FROM `permissions_categories`;
INSERT INTO `permissions` (`name`, `permission_category_id`) SELECT 'delete', `id` FROM `permissions_categories`;
