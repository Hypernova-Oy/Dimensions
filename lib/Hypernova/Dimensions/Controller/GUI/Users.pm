package Hypernova::Dimensions::Controller::GUI::Users;

use Mojo::Base 'Mojolicious::Controller';

use Try::Tiny;

sub index {
    my $c = shift->openapi->valid_input or return;

    return try {
        $c->render(controller => "gui-users");
    } catch {$c->render(default_exception => $_);};
}

1;
