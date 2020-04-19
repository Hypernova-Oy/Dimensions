use utf8;
package Hypernova::Dimensions::Schema::Result::ApiKey;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Hypernova::Dimensions::Schema::Result::ApiKey

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<api_keys>

=cut

__PACKAGE__->table("api_keys");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 user_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 api_key

  data_type: 'varchar'
  is_nullable: 0
  size: 191

=head2 api_secret

  data_type: 'varchar'
  is_nullable: 0
  size: 191

=head2 active

  data_type: 'integer'
  default_value: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "user_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "api_key",
  { data_type => "varchar", is_nullable => 0, size => 191 },
  "api_secret",
  { data_type => "varchar", is_nullable => 0, size => 191 },
  "active",
  { data_type => "integer", default_value => 1, is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<api_key_UNIQUE>

=over 4

=item * L</api_key>

=back

=cut

__PACKAGE__->add_unique_constraint("api_key_UNIQUE", ["api_key"]);

=head1 RELATIONS

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


# Created by DBIx::Class::Schema::Loader v0.07048 @ 2020-04-22 17:12:13
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:BsW2Tq+5F+u/rG3+WGPZhA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
