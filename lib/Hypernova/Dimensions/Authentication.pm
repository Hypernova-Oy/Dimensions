package Hypernova::Dimensions::Authentication;

use Hypernova::Dimensions::Exceptions::Authentication;

use Digest::SHA qw(hmac_sha256_hex);
use Time::Local;

sub authorize {
    my ($self, $c, $cb) = @_;

    my $spec = $c->openapi->spec;
    my $securities = $spec->{security};

    return $c->$cb unless $securities;

    my $user;
    my $api_key;
    foreach my $security (@$securities) {
        return $c->$cb unless $security;

        # API key authentication
        if (exists $security->{'api_key'}) {
            $c->app->log->debug('API key authentication');
            $api_key = eval{$self->api_key_authentication(
                $c->app->schema,
                {
                    api_key => $c->req->headers->header('X-API-KEY'),
                    api_signature => $c->req->headers->header('X-API-SIGNATURE'),
                    nonce => $c->req->headers->header('X-API-NONCE'),
                    timestamp => $c->req->headers->header('X-API-TIMESTAMP')
                }
            )};
            return $c->render(status => 401, default_exception => 1) unless $api_key;

            if ($spec->{'x-permissions'} && !$api_key->active) {
                return $c->render(status => 403, openapi => {
                    errors => [ { message => 'API key not active', path => '/' } ]
                } );
            }

            $user = $api_key->user;
            $c->stash('user', $user);
            last;
        }
    }

    my $granted = $self->check_permissions($c, $spec->{'x-permissions'}, $user);
    return $c->render(status => 403, default_exception => 1) unless $granted;

    # store event to eventlog
    $c->app->schema->resultset(
        'EventLog'
    )->create({
        user_id => $api_key ? $api_key->user_id : undef,
        target => $c->req->url->to_abs,
        description => Data::Dumper::Dumper($c->req->json),
        event => uc($c->req->method),
    });

    return $c->$cb;
}

sub api_key_authentication {
    my ($self, $schema, $headers) = @_;

    my $user_api_key = _check_header(
        'api_key', $headers->{api_key}
    );
    my $user_api_signature = _check_header(
        'api_signature', $headers->{api_signature}
    );
    my $user_nonce = _check_header(
        'nonce', $headers->{nonce}
    );
    my $user_timestamp = _check_header(
        'timestamp', $headers->{timestamp}
    );

    my $api_key = $schema->resultset(
        'ApiKey'
    )->find({ api_key => $user_api_key });

    return 0 unless $api_key;

    # Check nonce
    return 0 if $schema->resultset(
        'EventLog'
    )->find({
        user_id => $api_key->user_id,
        target => "nonce_$user_nonce",
    });

    # Check timestamp - user's timestamp must not be more than 15 minutes old
    my $timestamp = time();
    return 0 if ($user_timestamp < $timestamp-15*60);

    # Calculate signature
    my $api_signature = hmac_sha256_hex(
        $api_key->api_key,
        $api_key->api_secret.$user_nonce.$user_timestamp
    );

    return 0 unless $api_signature eq $user_api_signature;

    # Register nonce
    $schema->resultset(
        'EventLog'
    )->create({
        user_id => $api_key->user_id,
        target => "nonce_$user_nonce",
    });

    return $api_key;
}

sub check_permissions {
    my ($self, $c, $permissions, $user) = @_;

    foreach my $permission_category (keys %$permissions) {
        $permission_category = $c->app->schema->resultset(
            'PermissionsCategory'
        )->find({
            name => $permission_category
        });

        return 0 unless $permission_category;

        foreach my $permission_name (@{$permissions->{$permission_category->name}}) {
            my $permission = $c->app->schema->resultset(
                'Permission'
            )->find({
                name => $permission_name,
                permission_category_id => $permission_category->id,
            });
            return 0 unless $permission;
            return $c->app->schema->resultset(
                'UsersPermission'
            )->find({
                permission_id => $permission->id,
                user_id => $user->id,
            })?1:0;
        }
    }

    return 1;
}

sub _check_header {
    my ($name, $value) = @_;

    Hypernova::Dimensions::Exception::Authentication::MissingParameter->throw(
        error => 'Missing a header',
        parameter => "$name"
    ) unless defined $value;

    return $value;
}

1;
