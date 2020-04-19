package Hypernova::Dimensions::Controller::GUI::Dimensions;

use Mojo::Base 'Mojolicious::Controller';

use Try::Tiny;

sub product {
    my $c = shift->openapi->valid_input or return;

    return try {
        $c->render(controller => 'gui-dimensions', action => 'products');
    } catch {$c->render(default_exception => $_);};
}

sub user {
    my $c = shift->openapi->valid_input or return;

    return try {
        $c->render(controller => 'gui-dimensions', action => 'users');
    } catch {$c->render(default_exception => $_);};
}

1;
