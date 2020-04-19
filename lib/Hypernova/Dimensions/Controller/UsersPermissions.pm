package Hypernova::Dimensions::Controller::UsersPermissions;

use Mojo::Base 'Mojolicious::Controller';

use Try::Tiny;

sub list {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $params = $c->req->params->to_hash;
        my $objects = $c->schema->resultset('UsersPermission')->search($params);

        $c->render(status => 200, openapi => {
            records => [ map { $_->{_column_data} } $objects->all ]
        });
    } catch {$c->render(default_exception => $_);};
}

sub get {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $id = $c->param('id');
        my $object = $c->schema->resultset('UsersPermission')->find($id);

        return $c->render(status => 404, default_exception => 1) unless $object;

        $c->render(status => 200, openapi => { $object->get_columns });
    } catch {$c->render(default_exception => $_);};
}

sub add {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $params = $c->req->json;
        my $object = $c->schema->resultset('UsersPermission')->create($params);
           $object = $c->schema->resultset('UsersPermission')->find($object->id);

        $c->render(status => 201, openapi => { $object->get_columns });
    } catch {$c->render(default_exception => $_);};
}

sub edit {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $id = $c->param('id');
        my $object = $c->schema->resultset('UsersPermission')->find($id);

        return $c->render(status => 404, default_exception => 1) unless $object;

        my $params = $c->req->json;

        $object->update($params);
        $object = $c->schema->resultset('UsersPermission')->find($object->id);

        $c->render(status => 200, openapi => { $object->get_columns });
    } catch {$c->render(default_exception => $_);};
}

sub delete {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $id = $c->param('id');
        my $object = $c->schema->resultset('UsersPermission')->find($id);

        return $c->render(status => 404, default_exception => 1) unless $object;

        $object->delete;

        $c->render(status => 204, openapi => {});
    } catch {$c->render(default_exception => $_);};
}

1;
