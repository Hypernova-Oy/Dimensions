package t::lib::TestHelper;

use Digest::SHA qw(hmac_sha256_hex);
use Time::Local;

sub new {
    my ($class, $params) = @_;

    my $self = $params;

    bless $self, $class;
    return $self;
}

sub tx {
    my ($self, $tx, $params) = @_;

    my $schema = $self->{schema};
    my $t = $self->{t};

    if ($params->{auth}) {
        $params->{user} = defined $params->{user} ? $params->{user} :
            $schema->resultset('User')->find_or_create({
                username => 'admin',
            });
        my $user = $params->{user};

        my $api_key = $schema->resultset('ApiKey')->find_or_create({
            api_key => 'key',
            api_secret => 'secret',
            user_id => $user->id,
        });

        my $permissions = $params->{auth}->{permissions};
        foreach my $permission_cat (keys %$permissions) {
            my $permission_cat_id = $schema->resultset('PermissionsCategory')->
                find({ name => $permission_cat })->id;

            foreach my $permission (@{$permissions->{$permission_cat}}) {
                my $permission_id = $schema->resultset('Permission')->
                find({
                    name => $permission,
                    permission_category_id => $permission_cat_id
                })->id;

                $schema->resultset('UsersPermission')->find_or_create({
                    permission_id => $permission_id,
                    user_id => $user->id
                });

                $t->app->log->debug(
                    "Added permission $permission_cat.$permission");
            }
        }

        my $nonce = int(rand(1000000000));
        my $timestamp = time();

        my $api_signature = hmac_sha256_hex(
            $api_key->api_key,
            $api_key->api_secret.$nonce.$timestamp
        );

        $tx->req->headers->add('X-API-KEY' => $api_key->api_key);
        $tx->req->headers->add('X-API-SIGNATURE' => $api_signature);
        $tx->req->headers->add('X-API-NONCE' => $nonce);
        $tx->req->headers->add('X-API-TIMESTAMP' => $timestamp);
    }

    return $tx;
}

1;
