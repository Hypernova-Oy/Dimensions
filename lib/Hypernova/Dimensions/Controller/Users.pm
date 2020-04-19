package Hypernova::Dimensions::Controller::Users;

use Mojo::Base 'Mojolicious::Controller';

use Try::Tiny;

sub list {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $params = $c->req->params->to_hash;
        my $objects = $c->schema->resultset('User')->search($params);

        $c->render(status => 200, openapi => {
            records => [ map { $_->{_column_data} } $objects->all ]
        });
    } catch {$c->render(default_exception => $_);};
}

sub get {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $id = $c->param('id');
        my $object = $c->schema->resultset('User')->find($id);

        return $c->render(status => 404, default_exception => 1) unless $object;

        $c->render(status => 200, openapi => { $object->get_columns });
    } catch {$c->render(default_exception => $_);};
}

sub add {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $params = $c->req->json;
        my $object = $c->schema->resultset('User')->create($params);
           $object = $c->schema->resultset('User')->find($object->id);

        $c->render(status => 201, openapi => { $object->get_columns });
    } catch {$c->render(default_exception => $_);};
}

sub edit {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $id = $c->param('id');
        my $object = $c->schema->resultset('User')->find($id);

        return $c->render(status => 404, default_exception => 1) unless $object;

        my $params = $c->req->json;

        $object->update($params);
        $object = $c->schema->resultset('User')->find($object->id);

        $c->render(status => 200, openapi => { $object->get_columns });
    } catch {$c->render(default_exception => $_);};
}

sub delete {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $id = $c->param('id');
        my $object = $c->schema->resultset('User')->find($id);

        return $c->render(status => 404, default_exception => 1) unless $object;

        $object->delete;

        $c->render(status => 204, openapi => {});
    } catch {$c->render(default_exception => $_);};
}

sub dimensions {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $users = $c->schema->resultset('User')->search();

        my $search_params = $c->date_range_params();
        my $totals = [];
        foreach my $user ($users->all()) {
            my $total = 0;
            my $user_id = $user->id;
            my $username = $user->username;
            $search_params->{user_id} = $user_id;

            my $account_entries_user_dimensions = $c->schema->resultset(
            'AccountEntry')->search(
                $search_params, {
                join => 'account_entries_user_dimensions',
                '+select' => ['account_entries_user_dimensions.amount'],
                '+as' => ['user_dimension_amount'],
                order_by => 'me.created_at'
            });

            foreach my $user_dimension ($account_entries_user_dimensions->all()) {
                my $amount = $user_dimension->get_column('user_dimension_amount');
                $total+=$amount if defined $amount && $amount;
            }
            push @{$totals}, {
                user_id => $user_id,
                username => $username,
                total => $total
            };
        }
        $c->render( status => 200, openapi => { records => $totals } );
    } catch {$c->render(default_exception => $_);};
}

1;
