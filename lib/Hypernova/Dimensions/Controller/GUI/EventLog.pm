package Hypernova::Dimensions::Controller::GUI::EventLog;

use Mojo::Base 'Mojolicious::Controller';

use Try::Tiny;

sub index {
    my $c = shift->openapi->valid_input or return;

    return try {
        $c->render(controller => "gui-eventlogs");
    } catch {$c->render(default_exception => $_);};
}

1;
