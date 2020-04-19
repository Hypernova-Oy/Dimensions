use utf8;
package Hypernova::Dimensions::Schema::Result::User;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Hypernova::Dimensions::Schema::Result::User

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<users>

=cut

__PACKAGE__->table("users");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 username

  data_type: 'varchar'
  is_nullable: 0
  size: 45

=head2 created_at

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  default_value: 'CURRENT_TIMESTAMP'
  is_nullable: 0

=head2 modified_at

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  default_value: 'CURRENT_TIMESTAMP'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "username",
  { data_type => "varchar", is_nullable => 0, size => 45 },
  "created_at",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    default_value => "CURRENT_TIMESTAMP",
    is_nullable => 0,
  },
  "modified_at",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    default_value => "CURRENT_TIMESTAMP",
    is_nullable => 1,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<username_UNIQUE>

=over 4

=item * L</username>

=back

=cut

__PACKAGE__->add_unique_constraint("username_UNIQUE", ["username"]);

=head1 RELATIONS

=head2 account_entries_user_dimensions

Type: has_many

Related object: L<Hypernova::Dimensions::Schema::Result::AccountEntriesUserDimension>

=cut

__PACKAGE__->has_many(
  "account_entries_user_dimensions",
  "Hypernova::Dimensions::Schema::Result::AccountEntriesUserDimension",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 api_keys

Type: has_many

Related object: L<Hypernova::Dimensions::Schema::Result::ApiKey>

=cut

__PACKAGE__->has_many(
  "api_keys",
  "Hypernova::Dimensions::Schema::Result::ApiKey",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 users_permissions

Type: has_many

Related object: L<Hypernova::Dimensions::Schema::Result::UsersPermission>

=cut

__PACKAGE__->has_many(
  "users_permissions",
  "Hypernova::Dimensions::Schema::Result::UsersPermission",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07048 @ 2020-04-22 12:22:43
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:UTrrzw8ZvmRFH9tQIfQWlA

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
