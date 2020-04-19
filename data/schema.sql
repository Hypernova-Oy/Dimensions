SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Table `users`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `users` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `username` VARCHAR(45) NOT NULL,
  `created_at` DATETIME NOT NULL DEFAULT NOW(),
  `modified_at` DATETIME NULL DEFAULT NOW(),
  PRIMARY KEY (`id`),
  UNIQUE INDEX `username_UNIQUE` (`username` ASC)
)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `permissions_categories`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `permissions_categories` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `name_UNIQUE` (`name` ASC)
)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `permissions`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `permissions` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) NOT NULL,
  `permission_category_id` INT NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `name_UNIQUE` (`name` ASC, `permission_category_id`),
  INDEX `fk_permissions_1_idx` (`permission_category_id` ASC),
  CONSTRAINT `fk_permissions_1`
    FOREIGN KEY (`permission_category_id`)
    REFERENCES `permissions_categories` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `users_permissions`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `users_permissions` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `user_id` INT NOT NULL,
  `permission_id` INT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_users_permissions_1_idx` (`user_id` ASC),
  INDEX `fk_users_permissions_2_idx` (`permission_id` ASC),
  CONSTRAINT `fk_users_permissions_1`
    FOREIGN KEY (`user_id`)
    REFERENCES `users` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_users_permissions_2`
    FOREIGN KEY (`permission_id`)
    REFERENCES `permissions` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `api_keys`
-- -----------------------------------------------------

CREATE TABLE IF NOT EXISTS `api_keys` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `user_id` INT NOT NULL,
    `api_key` VARCHAR(191) NOT NULL,
    `api_secret` VARCHAR(191) NOT NULL,
    `active` int(1) DEFAULT 1,
    PRIMARY KEY (`id`),
    UNIQUE INDEX `api_key_UNIQUE` (`api_key` ASC),
    INDEX `fk_api_keys_1_idx` (`user_id` ASC),
    CONSTRAINT `fk_api_keys_1`
      FOREIGN KEY (`user_id`)
      REFERENCES `users` (`id`)
      ON DELETE CASCADE
      ON UPDATE CASCADE
)
ENGINE=InnoDB;


-- -----------------------------------------------------
-- Table `accounts`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `accounts` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `code` INT NOT NULL,
  `name` VARCHAR(191) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `code_UNIQUE` (`code` ASC)
)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `account_entries`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `account_entries` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `account_id` INT NOT NULL,
  `amount` DECIMAL(13,2) NOT NULL DEFAULT 0,
  `description` VARCHAR(191) NULL,
  `created_at` DATETIME NOT NULL DEFAULT NOW(),
  `modified_at` DATETIME NULL DEFAULT NOW(),
  PRIMARY KEY (`id`),
  INDEX `fk_account_entries_1_idx` (`account_id` ASC),
  CONSTRAINT `fk_account_entries_1`
    FOREIGN KEY (`account_id`)
    REFERENCES `accounts` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `products`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `products` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(191) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `name_UNIQUE` (`name` ASC)
)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `account_entries_product_dimensions`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `account_entries_product_dimensions` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `account_entry_id` INT NOT NULL,
  `product_id` INT NOT NULL,
  `amount` DECIMAL(13,2) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `entries_products_UNIQUE` (`account_entry_id` ASC, `product_id` ASC),
  INDEX `fk_account_entries_dimensions_2_idx` (`product_id` ASC),
  CONSTRAINT `fk_account_entries_dimensions_1`
    FOREIGN KEY (`account_entry_id`)
    REFERENCES `account_entries` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_account_entries_dimensions_2`
    FOREIGN KEY (`product_id`)
    REFERENCES `products` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `account_entries_user_dimensions`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `account_entries_user_dimensions` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `account_entry_id` INT NOT NULL,
  `user_id` INT NOT NULL,
  `amount` DECIMAL(13,2) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `account_user_UNIQUE` (`account_entry_id` ASC, `user_id` ASC),
  INDEX `fk_account_entries_user_dimensions_2_idx` (`user_id` ASC),
  CONSTRAINT `fk_account_entries_user_dimensions_1`
    FOREIGN KEY (`account_entry_id`)
    REFERENCES `account_entries` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_account_entries_user_dimensions_2`
    FOREIGN KEY (`user_id`)
    REFERENCES `users` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `event_log`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `event_log` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `user_id` INT NOT NULL,
  `target` VARCHAR(191) NULL,
  `event` VARCHAR(191) NULL,
  `description` VARCHAR(255) NULL,
  `created_at` DATETIME NOT NULL DEFAULT NOW(),
  PRIMARY KEY (`id`)
)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
