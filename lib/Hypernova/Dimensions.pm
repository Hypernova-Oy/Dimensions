package Hypernova::Dimensions;

use Mojo::Base 'Mojolicious';

use Hypernova::Dimensions::Authentication;

sub startup {
    my $self = shift;

    $self->app->log->level('debug') if $ENV{DEBUG};

    $self->plugin(
        'OpenAPI' => {
            url   => $self->home->rel_file('public/openapi.json'),
            schema => 'v3',
            security => {
                api_key => sub {
                    my ($c, $definition, $scopes, $cb) = @_;
                    return Hypernova::Dimensions::Authentication->authorize(
                        $c, $cb
                    );
                }
            }
        }
    );

    # Load configuration from hash returned by config file
    my $config = $self->plugin('Config');

    my $database = $config->{database};

    $self->plugin(
        'DBIC' => {
            schema => {
                'Hypernova::Dimensions::Schema' => [
                    $database->{dsn},
                    $database->{username},
                    $database->{password},
                    { RaiseError => 1 }
                ],
            }
        }
    );

    # Configure the application
    $self->secrets($config->{secrets});

    $self->plugin('Hypernova::Dimensions::Plugin::QueryParams');

    $self->app->hook(before_render => \&default_exception_handling);
    $self->app->hook(around_action => sub {
        my ($next, $c, $action, $last) = @_;
        # Datatables set a query parameter "_" in order to handle caching
        # issues. This workaround removes that query parameter from actually
        # reaching controllers
        $c->req->params->remove('_') if $c->param('_');
        return $next->();
    });
}

sub default_exception_handling {
    my ($c, $args) = @_;

    unless ($c->stash('rendered')) {
        $c->stash('rendered', 1);

        $c->app->log->debug(Data::Dumper::Dumper($args));

        if (defined $args->{default_exception}) {
            my $status = $args->{status} || 500;
            delete $args->{default_exception};
            $args->{handler} = 'openapi';
            return $c->render(status => $status, openapi => { errors => [{
                message => _get_default_error_message($status),
                path => '/',
            }]}) ;
        }
    }
}

sub _get_default_error_message {
    my ($code) = @_;

    return 'Bad request' if $code == 400;
    return 'Unauthorized' if $code == 401;
    return 'Insufficient permissions' if $code == 403;
    return 'Resource not found.' if $code == 404;
    return 'Something went wrong. Contact the administrator.' if $code == 500;
    return 'Server under maintenance' if $code == 503;
}

1;
