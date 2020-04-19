use utf8;
package Hypernova::Dimensions::Schema::Result::AccountEntriesUserDimension;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Hypernova::Dimensions::Schema::Result::AccountEntriesUserDimension

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<account_entries_user_dimensions>

=cut

__PACKAGE__->table("account_entries_user_dimensions");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 account_entry_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 user_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 amount

  data_type: 'decimal'
  is_nullable: 0
  size: [13,2]

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "account_entry_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "user_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "amount",
  { data_type => "decimal", is_nullable => 0, size => [13, 2] },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<account_user_UNIQUE>

=over 4

=item * L</account_entry_id>

=item * L</user_id>

=back

=cut

__PACKAGE__->add_unique_constraint("account_user_UNIQUE", ["account_entry_id", "user_id"]);

=head1 RELATIONS

=head2 account_entry

Type: belongs_to

Related object: L<Hypernova::Dimensions::Schema::Result::AccountEntry>

=cut

__PACKAGE__->belongs_to(
  "account_entry",
  "Hypernova::Dimensions::Schema::Result::AccountEntry",
  { id => "account_entry_id" },
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
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:BxPqLdjBTKly9LTZaqT79A


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
