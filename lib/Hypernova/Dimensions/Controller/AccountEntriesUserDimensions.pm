package Hypernova::Dimensions::Controller::AccountEntriesUserDimensions;

use Mojo::Base 'Mojolicious::Controller';

use Try::Tiny;

sub list {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $params = $c->req->params->to_hash;
        my $objects = $c->schema->resultset('AccountEntriesUserDimension')->search($params);

        $c->render(status => 200, openapi => {
            records => [ map { $_->{_column_data} } $objects->all ]
        });
    } catch {$c->render(default_exception => $_);};
}

sub get {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $id = $c->param('id');
        my $object = $c->schema->resultset('AccountEntriesUserDimension')->find($id);

        return $c->render(status => 404, default_exception => 1) unless $object;

        $c->render(status => 200, openapi => { $object->get_columns });
    } catch {$c->render(default_exception => $_);};
}

sub add {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $params = $c->req->json;
        my $object = $c->schema->resultset('AccountEntriesUserDimension')->create($params);
           $object = $c->schema->resultset('AccountEntriesUserDimension')->find($object->id);

        $c->render(status => 201, openapi => { $object->get_columns });
    } catch {$c->render(default_exception => $_);};
}

sub edit {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $id = $c->param('id');
        my $object = $c->schema->resultset('AccountEntriesUserDimension')->find($id);

        return $c->render(status => 404, default_exception => 1) unless $object;

        my $params = $c->req->json;

        $object->update($params);
        $object = $c->schema->resultset('AccountEntriesUserDimension')->find($object->id);

        $c->render(status => 200, openapi => { $object->get_columns });
    } catch {$c->render(default_exception => $_);};
}

sub delete {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $id = $c->param('id');
        my $object = $c->schema->resultset('AccountEntriesUserDimension')->find($id);

        return $c->render(status => 404, default_exception => 1) unless $object;

        $object->delete;

        $c->render(status => 204, openapi => {});
    } catch {$c->render(default_exception => $_);};
}

sub expanded {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $search_params = {};
        my $user_id = $c->param('user_id');
        $search_params->{'me.id'} = $user_id if defined $user_id;
        my $users = $c->schema->resultset('User')->search($search_params);

        my $totals = [];
        foreach my $user ($users->all()) {
            my $user_id = $user->id;
            my $username = $user->username;
            $search_params = $c->date_range_params();
            $search_params->{'account_entries_user_dimensions.user_id'} = $user_id;
            $search_params->{'account_entries_user_dimensions.amount'} = { '!=' => 0 };

            my $account_entries_user_dimensions = $c->schema->resultset(
            'AccountEntry')->search(
                $search_params, {
                join => 'account_entries_user_dimensions',
                '+select' => ['account_entries_user_dimensions.amount, account_entries_user_dimensions.user_id'],
                '+as' => ['user_dimension_amount', 'user_dimension_user_id'],
                order_by => 'me.created_at'
            });

            my $entries = [];
            foreach my $user_dimension ($account_entries_user_dimensions->all()) {
                my $account_entry_id = $user_dimension->id;
                my $date = $user_dimension->created_at;
                my $description = $user_dimension->description;
                my $total_amount = $user_dimension->amount;
                my $user_amount = $user_dimension->get_column('user_dimension_amount') || 0;

                next unless $user_amount;

                my $share = ($total_amount && ($total_amount > 0 || $total_amount < 0))
                    ? sprintf('%.2f', ($user_amount/$total_amount)*100)
                    : 0; #0e0 workaround
                push @{$entries}, {
                    account_entry_id    => $account_entry_id,
                    date                => $date,
                    description         => $description,
                    total_amount        => $total_amount,
                    user_amount         => $user_amount,
                    share               => $share,
                };
            }
            push @{$totals}, {
                user_id => $user_id,
                username => $username,
                entries => $entries
            };
        }
        $c->render( status => 200, openapi => { records => $totals } );
    } catch {$c->render(default_exception => $_);};
}

1;
