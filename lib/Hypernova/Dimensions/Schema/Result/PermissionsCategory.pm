use utf8;
package Hypernova::Dimensions::Schema::Result::PermissionsCategory;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Hypernova::Dimensions::Schema::Result::PermissionsCategory

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<permissions_categories>

=cut

__PACKAGE__->table("permissions_categories");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 45

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 45 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<name_UNIQUE>

=over 4

=item * L</name>

=back

=cut

__PACKAGE__->add_unique_constraint("name_UNIQUE", ["name"]);

=head1 RELATIONS

=head2 permissions

Type: has_many

Related object: L<Hypernova::Dimensions::Schema::Result::Permission>

=cut

__PACKAGE__->has_many(
  "permissions",
  "Hypernova::Dimensions::Schema::Result::Permission",
  { "foreign.permission_category_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07048 @ 2020-04-22 15:55:55
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:PDWiwmq2OsPfjDoHH9IeHg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
