<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Third Party Services
    |--------------------------------------------------------------------------
    |
    | This file is for storing the credentials for third party services such
    | as Stripe, Mailgun, Mandrill, and others. This file provides a sane
    | default location for this type of information, allowing packages
    | to have a conventional place to find your various credentials.
    |
    */

    'mailgun' => [
        'domain' => '',
        'secret' => '',
    ],

    'mandrill' => [
        'secret' => '',
    ],

    'ses' => [
        'key'    => '',
        'secret' => '',
        'region' => 'us-east-1',
    ],

    'stripe' => [
        'model'  => App\User::class,
        'key'    => '',
        'secret' => '',
    ],

    // SOCIAL SERVICES
    // TODO: Change redirects
    'facebook' => [
    'client_id' => '1459209504372923',
    'client_secret' => '93b84169e32a1cad857c0ab7105c2762',
    'redirect' => 'http://paydaycharity.org',
    ],

    'google' => [
    'client_id' => '832042376397-g9gldd1bhps132no05i80favrvjk59vu.apps.googleusercontent.com',
    'client_secret' => '_fd9OGTJmuHGAnAjFiZd-Sxs',
    'redirect' => 'http://paydaycharity.org',
    ],



];
