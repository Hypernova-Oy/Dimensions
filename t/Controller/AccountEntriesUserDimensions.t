#!/usr/bin/perl

use strict;
use warnings;

use Test::Mojo;
use Test::More;

use t::lib::TestHelper;

my $t = Test::Mojo->new('Hypernova::Dimensions');
my $schema = $t->app->schema;

my $test = t::lib::TestHelper->new({
    schema => $schema,
    t => $t,
});

use_ok('Hypernova::Dimensions::Controller::AccountEntriesUserDimensions');

subtest 'list() tests' => sub {
    plan tests => 6;

    $schema->txn_begin;

    my $account = $schema->resultset('Account')->create({
        code => 1000,
        name => 'test account',
    });

    my $user1 = $schema->resultset('User')->create({
        username => 'test user',
    });

    my $user2 = $schema->resultset('User')->create({
        username => 'test user2',
    });

    my $entry1 = $schema->resultset('AccountEntry')->create({
        account_id => $account->id,
        amount => sprintf('%.2f', rand(1000) * 1000),
        description => 'test entry1 description',
    });

    my $entry2 = $schema->resultset('AccountEntry')->create({
        account_id => $account->id,
        amount => sprintf('%.2f', rand(1000) * 1000),
        description => 'test entry2 description',
    });

    my $aepd1 = $schema->resultset('AccountEntriesUserDimension')->create({
        account_entry_id => $entry1->id,
        user_id => $user1->id,
        amount => sprintf('%.2f', rand(1000) * 100),
    });

    my $aepd2 = $schema->resultset('AccountEntriesUserDimension')->create({
        account_entry_id => $entry1->id,
        user_id => $user2->id,
        amount => sprintf('%.2f', rand(1000) * 100),
    });

    my $aepd3 = $schema->resultset('AccountEntriesUserDimension')->create({
        account_entry_id => $entry2->id,
        user_id => $user1->id,
        amount => $entry2->amount,
    });

    my $tx = $test->tx(
        $t->ua->build_tx(GET => '/api/account/entries/user/dimensions'), {
            auth => {
                permissions => { 'account_entries_user_dimensions' =>['read'] }
            }
        }
    );

    $t->request_ok($tx)->status_is(200)
      ->json_is('/records/0/id', $aepd1->id)
      ->json_is('/records/0/amount', sprintf('%.2f', $aepd1->amount))
      ->json_is('/records/2/account_entry_id', $entry2->id)
      ->json_hasnt('/records/6');

    $schema->txn_rollback;
};

subtest 'get() tests' => sub {
    plan tests => 6;

    $schema->txn_begin;

    my $account = $schema->resultset('Account')->create({
        code => 1000,
        name => 'test account',
    });

    my $user1 = $schema->resultset('User')->create({
        username => 'test user',
    });

    my $entry1 = $schema->resultset('AccountEntry')->create({
        account_id => $account->id,
        amount => sprintf('%.2f', rand(1000) * 1000),
        description => 'test entry1 description',
    });

    my $aepd1 = $schema->resultset('AccountEntriesUserDimension')->create({
        account_entry_id => $entry1->id,
        user_id => $user1->id,
        amount => sprintf('%.2f', rand(1000) * 100),
    });

    my $tx = $test->tx(
        $t->ua->build_tx(GET => '/api/account/entries/user/dimensions/'.$aepd1->id), {
            auth => {
                permissions => { 'account_entries_user_dimensions' =>['read'] }
            }
        }
    );

    $t->request_ok($tx)->status_is(200)
      ->json_is('/id', $aepd1->id)
      ->json_is('/amount', sprintf('%.2f', $aepd1->amount))
      ->json_is('/account_entry_id', $entry1->id)
      ->json_is('/user_id', $user1->id);

    $schema->txn_rollback;
};

subtest 'add() tests' => sub {
    plan skip_all => 'todo';
};

subtest 'edit() tests' => sub {
    plan skip_all => 'todo';
};

subtest 'delete() tests' => sub {
    plan skip_all => 'todo';
};

done_testing();
