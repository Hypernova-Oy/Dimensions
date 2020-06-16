package Hypernova::Dimensions::Controller::GUI::Editor;

use Mojo::Base 'Mojolicious::Controller';

use Try::Tiny;

sub index {
    my $c = shift->openapi->valid_input or return;

    return try {
        $c->render(controller => "gui-editor");
    } catch {$c->render(default_exception => $_);};
}

sub datatable_content {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $accounts = $c->schema->resultset('Account')->search();
        my $account_entries = $c->schema->resultset('AccountEntry')->search();
        my $account_entries_product_dimensions = $c->schema->resultset(
            'AccountEntriesProductDimension')->search();
        my $account_entries_user_dimensions = $c->schema->resultset(
            'AccountEntriesUserDimension')->search();
        my $products = $c->schema->resultset('Product')->search()->all();
        my $users = $c->schema->resultset('User')->search();

        my $dimensions = [];
        foreach my $account_entry ($account_entries->all()) {
            my $account_entry_id = $account_entry->id;

            my $entry = {
                account_entry_id        => $account_entry_id,
                amount                  => $account_entry->amount,
                date                    => $account_entry->created_at,
                description             => $account_entry->description,
                product                 => [],
                product_dim_complete    => 0,
                user                    => [],
                user_dim_complete       => 0,
            };

            $c->_get_product_dimensions(
                $account_entry_id, $entry
            );

            $c->_get_user_dimensions(
                $account_entry_id, $entry
            );

            # turn dimensions complete from amount to percentage
            my $amount = $account_entry->amount;
            if ($amount != 0) {
                $entry->{product_dim_complete} = abs(sprintf('%.2f',
                    ($entry->{product_dim_complete}/$amount*100)));
                $entry->{user_dim_complete} = abs(sprintf('%.2f',
                    ($entry->{user_dim_complete}/$amount*100)));
            } elsif ($amount == 0) {
                $entry->{product_dim_complete} = $entry->{product_dim_complete} == 0
                ? 100.00
                : 999.99;
                $entry->{user_dim_complete} = $entry->{user_dim_complete} == 0
                ? 100.00
                : 999.99;
            }

            push @{$dimensions}, $entry;
        }

        $c->render( json => { data => $dimensions } );
    } catch {$c->render(default_exception => $_);};
}

sub _get_product_dimensions {
    my ($c, $account_entry_id, $entry) = @_;

    my $products = $c->schema->resultset('Product')->search();

    foreach my $product ($products->all()) {
        my $product_id = $product->id;
        my $product_dimensions = $c->schema->resultset(
            'AccountEntriesProductDimension')->search({
                account_entry_id    => $account_entry_id,
                product_id          => $product_id,
        })->single();
        my $product_dimension = {
            id          => undef,
            product_id  => $product_id,
            amount      => undef,
        };
        if ($product_dimensions) {
            $product_dimension->{amount} = $product_dimensions->amount;
            $product_dimension->{id}     = $product_dimensions->id;
        }

        $entry->{product_dim_complete} += $product_dimension->{amount} || 0;

        push @{$entry->{product}}, $product_dimension;
    }
}

sub _get_user_dimensions {
    my ($c, $account_entry_id, $entry) = @_;

    my $users = $c->schema->resultset('User')->search();

    foreach my $user ($users->all()) {
        my $user_id = $user->id;
        my $user_dimensions = $c->schema->resultset(
            'AccountEntriesUserDimension')->search({
                account_entry_id    => $account_entry_id,
                user_id             => $user_id,
        })->single();
        my $user_dimension = {
            id      => undef,
            user_id => $user_id,
            amount  => undef,
        };
        if ($user_dimensions) {
            $user_dimension->{amount} = $user_dimensions->amount;
            $user_dimension->{id}     = $user_dimensions->id;
        }

        $entry->{user_dim_complete} += $user_dimension->{amount} || 0;

        push @{$entry->{user}}, $user_dimension;
    }
}

1;
