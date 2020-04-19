use utf8;
package Hypernova::Dimensions::Schema::Result::AccountEntry;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Hypernova::Dimensions::Schema::Result::AccountEntry

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<account_entries>

=cut

__PACKAGE__->table("account_entries");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 account_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 amount

  data_type: 'decimal'
  default_value: 0
  is_nullable: 0
  size: [13,2]

=head2 description

  data_type: 'varchar'
  is_nullable: 1
  size: 191

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
  "account_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "amount",
  { data_type => "decimal", default_value => 0, is_nullable => 0, size => [13, 2] },
  "description",
  { data_type => "varchar", is_nullable => 1, size => 191 },
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

=head1 RELATIONS

=head2 account

Type: belongs_to

Related object: L<Hypernova::Dimensions::Schema::Result::Account>

=cut

__PACKAGE__->belongs_to(
  "account",
  "Hypernova::Dimensions::Schema::Result::Account",
  { id => "account_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 account_entries_product_dimensions

Type: has_many

Related object: L<Hypernova::Dimensions::Schema::Result::AccountEntriesProductDimension>

=cut

__PACKAGE__->has_many(
  "account_entries_product_dimensions",
  "Hypernova::Dimensions::Schema::Result::AccountEntriesProductDimension",
  { "foreign.account_entry_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 account_entries_user_dimensions

Type: has_many

Related object: L<Hypernova::Dimensions::Schema::Result::AccountEntriesUserDimension>

=cut

__PACKAGE__->has_many(
  "account_entries_user_dimensions",
  "Hypernova::Dimensions::Schema::Result::AccountEntriesUserDimension",
  { "foreign.account_entry_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07048 @ 2020-04-22 12:22:43
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:SlIbfwaSrOFlcmvo9y55mA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
