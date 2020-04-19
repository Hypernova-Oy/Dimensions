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

use_ok('Hypernova::Dimensions::Controller::Users');

subtest 'list() tests' => sub {
    plan tests => 7;

    $schema->txn_begin;

    foreach my $id (1..5) {
        $schema->resultset('User')->create({
            username => 'Lari' . $id,
        });
    }

    my $user = $schema->resultset('User')->create({
        username => 'Lari',
    });

    my $tx = $test->tx(
        $t->ua->build_tx(GET => '/api/users'), {
            user => $user,
            auth => {
                permissions => { 'users' => ['read'] }
            }
        }
    );

    $t->request_ok($tx)->status_is(200)
      ->json_is('/records/0/username', 'Lari1')
      ->json_has('/records/0/created_at')
      ->json_has('/records/0/modified_at')
      ->json_has('/records/5/username', 'Lari4')
      ->json_hasnt('/records/6');

    $schema->txn_rollback;
};

subtest 'get() tests' => sub {
    plan tests => 9;

    $schema->txn_begin;

    my $user = $schema->resultset('User')->create({
        username => 'Lari',
    });

    my $tx = $test->tx(
        $t->ua->build_tx(GET => '/api/users/-1'), {
            user => $user,
            auth => {
                permissions => { 'users' => ['read'] }
            }
        }
    );
    $t->request_ok($tx)->status_is(404)
      ->json_is('/errors/0/message', 'Resource not found.');

    $tx = $test->tx(
        $t->ua->build_tx(GET => '/api/users/' . $user->id), {
            user => $user,
            auth => {
                permissions => { 'users' => ['read'] }
            }
        }
    );
    $t->request_ok($tx)->status_is(200)
      ->json_is('/username', 'Lari')
      ->json_has('/created_at')
      ->json_has('/modified_at')
      ->json_hasnt('/nonexisting_property');

    $schema->txn_rollback;
};

subtest 'add() tests' => sub {
    plan tests => 6;

    $schema->txn_begin;

    my $admin;
    my $user = {
        username => 'Lari',
    };

    my $tx = $test->tx(
        $t->ua->build_tx(POST => '/api/users/' => json => $user), {
            user => $admin,
            auth => {
                permissions => { 'users' => ['create'] }
            }
        }
    );
    $t->request_ok($tx)->status_is(201)
      ->json_is('/username', 'Lari')
      ->json_has('/created_at')
      ->json_has('/modified_at')
      ->json_hasnt('/nonexisting_property');

    $schema->txn_rollback;
};

subtest 'edit() tests' => sub {
    plan tests => 9;

    $schema->txn_begin;

    my $admin;
    my $user = {
        username => 'Lari',
    };

    $user = $schema->resultset('User')->create($user);
    $user = { $schema->resultset('User')->find($user->id)->get_columns };

    $user->{username} = 'Lari edited';

    my $user_id = delete $user->{id};
    delete $user->{created_at};
    delete $user->{modified_at};

    my $tx = $test->tx(
        $t->ua->build_tx(PUT => '/api/users/-1' => json => $user), {
            user => $admin,
            auth => {
                permissions => { 'users' => ['update'] }
            }
        }
    );
    $t->request_ok($tx)->status_is(404)
      ->json_is('/errors/0/message', 'Resource not found.');

    $tx = $test->tx(
        $t->ua->build_tx(PUT => "/api/users/$user_id" => json => $user), {
            user => $admin,
            auth => {
                permissions => { 'users' => ['update'] }
            }
        }
    );
    $t->request_ok($tx)->status_is(200)
      ->json_is('/username', 'Lari edited')
      ->json_has('/created_at')
      ->json_has('/modified_at')
      ->json_hasnt('/nonexisting_property');

    $schema->txn_rollback;
};

subtest 'delete() tests' => sub {
    plan tests => 6;

    $schema->txn_begin;

    my $admin;
    my $user = $schema->resultset('User')->create({
        username => 'Lari',
    });
    my $tx = $test->tx(
        $t->ua->build_tx(DELETE => '/api/users/-1'), {
            user => $admin,
            auth => {
                permissions => { 'users' => ['delete'] }
            }
        }
    );
    $t->request_ok($tx)->status_is(404)
      ->json_is('/errors/0/message', 'Resource not found.');

    $tx = $test->tx(
        $t->ua->build_tx(DELETE => '/api/users/' . $user->id), {
            user => $admin,
            auth => {
                permissions => { 'users' => ['read'] }
            }
        }
    );
    $t->request_ok($tx)->status_is(204)
      ->content_is('', 'Empty response body');

    $schema->txn_rollback;
};

subtest 'expanded() tests' => sub {
    plan skip_all => 'todo';
};

done_testing();
