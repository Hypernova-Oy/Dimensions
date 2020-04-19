use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

my $t = Test::Mojo->new('Hypernova::Dimensions');
$t->get_ok('/api')->status_is(200)->content_like(qr/Hypernova Dimensions API/i);

done_testing();
