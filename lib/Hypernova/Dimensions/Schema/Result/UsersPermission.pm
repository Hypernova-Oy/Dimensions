use utf8;
package Hypernova::Dimensions::Schema::Result::UsersPermission;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Hypernova::Dimensions::Schema::Result::UsersPermission

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<users_permissions>

=cut

__PACKAGE__->table("users_permissions");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 user_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 permission_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "user_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "permission_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 permission

Type: belongs_to

Related object: L<Hypernova::Dimensions::Schema::Result::Permission>

=cut

__PACKAGE__->belongs_to(
  "permission",
  "Hypernova::Dimensions::Schema::Result::Permission",
  { id => "permission_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 user

Type: belongs_to

Related object: L<Hypernova::Dimensions::Schema::Result::User>

=cut

__PACKAGE__->belongs_to(
  "user",
  "Hypernova::Dimensions::Schema::Result::User",
  { id => "user_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07048 @ 2020-04-22 04:55:23
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:8x25sLeYtQFu4hKeyRmafQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
