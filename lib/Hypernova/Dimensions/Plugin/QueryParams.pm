package Hypernova::Dimensions::Plugin::QueryParams;

use base 'Mojolicious::Plugin';

sub register {

    my ($self, $app) = @_;

    $app->helper(date_range_params => sub {
        my ($c, $params) = @_;

        $params //= {};

        if ($c->param('date_start')) {
            $params->{date_start} = $c->param('date_start');
        }
        if ($c->param('date_end')) {
            $params->{date_end} = $c->param('date_end');
        }
        if ($params->{date_start} && $params->{date_end}) {
            $params->{'me.created_at'} = {
                '>=' => delete $params->{date_start},
                '<=' => delete $params->{date_end}
            };
        } elsif ($params->{date_start}) {
            $params->{'me.created_at'} = {
                '>=' => delete $params->{date_start}
            };
        } elsif ($params->{date_end}) {
            $params->{'me.created_at'} = {
                '<=' => delete $params->{date_end}
            };
        }

        return $params;
    } );

}

1;
