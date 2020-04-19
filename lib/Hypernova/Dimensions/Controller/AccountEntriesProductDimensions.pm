package Hypernova::Dimensions::Controller::AccountEntriesProductDimensions;

use Mojo::Base 'Mojolicious::Controller';

use Try::Tiny;

sub list {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $params = $c->req->params->to_hash;
        my $objects = $c->schema->resultset('AccountEntriesProductDimension')->search($params);

        $c->render(status => 200, openapi => {
            records => [ map { $_->{_column_data} } $objects->all ]
        });
    } catch {$c->render(default_exception => $_);};
}

sub get {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $id = $c->param('id');
        my $object = $c->schema->resultset('AccountEntriesProductDimension')->find($id);

        return $c->render(status => 404, default_exception => 1) unless $object;

        $c->render(status => 200, openapi => { $object->get_columns });
    } catch {$c->render(default_exception => $_);};
}

sub add {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $params = $c->req->json;
        my $object = $c->schema->resultset('AccountEntriesProductDimension')->create($params);
           $object = $c->schema->resultset('AccountEntriesProductDimension')->find($object->id);

        $c->render(status => 201, openapi => { $object->get_columns });
    } catch {$c->render(default_exception => $_);};
}

sub edit {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $id = $c->param('id');
        my $object = $c->schema->resultset('AccountEntriesProductDimension')->find($id);

        return $c->render(status => 404, default_exception => 1) unless $object;

        my $params = $c->req->json;

        $object->update($params);
        $object = $c->schema->resultset('AccountEntriesProductDimension')->find($object->id);

        $c->render(status => 200, openapi => { $object->get_columns });
    } catch {$c->render(default_exception => $_);};
}

sub delete {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $id = $c->param('id');
        my $object = $c->schema->resultset('AccountEntriesProductDimension')->find($id);

        return $c->render(status => 404, default_exception => 1) unless $object;

        $object->delete;

        $c->render(status => 204, openapi => {});
    } catch {$c->render(default_exception => $_);};
}

sub expanded {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $search_params = {};
        my $product_id = $c->param('product_id');
        $search_params->{'me.id'} = $product_id if defined $product_id;
        my $products = $c->schema->resultset('Product')->search($search_params);

        my $totals = [];
        foreach my $product ($products->all()) {
            my $product_id = $product->id;
            my $product_name = $product->name;
            $search_params = $c->date_range_params();
            $search_params->{'account_entries_product_dimensions.product_id'} = $product_id;
            $search_params->{'account_entries_product_dimensions.amount'} = { '!=' => 0 };

            my $account_entries_product_dimensions = $c->schema->resultset(
            'AccountEntry')->search(
                $search_params, {
                join => 'account_entries_product_dimensions',
                '+select' => ['account_entries_product_dimensions.amount, account_entries_product_dimensions.product_id'],
                '+as' => ['product_dimension_amount', 'product_dimension_product_id'],
                order_by => 'me.created_at'
            });

            my $entries = [];
            foreach my $product_dimension ($account_entries_product_dimensions->all()) {
                my $account_entry_id = $product_dimension->id;
                my $date = $product_dimension->created_at;
                my $description = $product_dimension->description;
                my $total_amount = $product_dimension->amount;
                my $product_amount = $product_dimension->get_column('product_dimension_amount') || 0;

                my $share = ($total_amount && ($total_amount > 0 || $total_amount < 0))
                    ? sprintf('%.2f', ($product_amount/$total_amount)*100)
                    : 0; #0e0 workaround
                push @{$entries}, {
                    account_entry_id    => $account_entry_id,
                    date                => $date,
                    description         => $description,
                    total_amount        => $total_amount,
                    product_amount         => $product_amount,
                    share               => $share,
                };
            }
            push @{$totals}, {
                product_id => $product_id,
                product_name => $product_name,
                entries => $entries
            };
        }
        $c->render( status => 200, openapi => { records => $totals } );
    } catch {$c->render(default_exception => $_);};
}

1;
