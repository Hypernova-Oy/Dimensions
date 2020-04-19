use utf8;
package Hypernova::Dimensions::Schema::Result::Account;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Hypernova::Dimensions::Schema::Result::Account

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<accounts>

=cut

__PACKAGE__->table("accounts");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 code

  data_type: 'integer'
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 191

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "code",
  { data_type => "integer", is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 191 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<code_UNIQUE>

=over 4

=item * L</code>

=back

=cut

__PACKAGE__->add_unique_constraint("code_UNIQUE", ["code"]);

=head1 RELATIONS

=head2 account_entries

Type: has_many

Related object: L<Hypernova::Dimensions::Schema::Result::AccountEntry>

=cut

__PACKAGE__->has_many(
  "account_entries",
  "Hypernova::Dimensions::Schema::Result::AccountEntry",
  { "foreign.account_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07048 @ 2020-04-22 17:12:13
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:YoPDh6uT8BUYu+NCSRSAfQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
