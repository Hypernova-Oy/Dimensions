package Hypernova::Dimensions::Controller::GUI::Products;

use Mojo::Base 'Mojolicious::Controller';

use Try::Tiny;

sub index {
    my $c = shift->openapi->valid_input or return;

    return try {
        $c->render(controller => "gui-products");
    } catch {$c->render(default_exception => $_);};
}

1;
