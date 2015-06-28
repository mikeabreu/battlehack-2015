<?php

use Illuminate\Database\Schema\Blueprint;
use Illuminate\Database\Migrations\Migration;

class CreateUsersTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('users', function (Blueprint $table) {
            $table->increments('id');
            $table->string('g_id');
            $table->string('fb_id');
            $table->string('bt_id');
            $table->timestamps();
        });

        Schema::create('charitys', function (Blueprint $table) {
            $table->increments('id');
            $table->string('name');
            $table->string('email')->unique();
            $table->string('password', 60);
            $table->rememberToken();
        });

        Schema::create('payments', function (Blueprint $table) {
            $table->integer('charity_id')->unsigned()
                ->references('id')->on('charitys')
                ->onDelete('cascade');
            $table->integer('user_id')->unsigned()
                ->references('id')->on('users')
                ->onDelete('cascade');
            $table->integer('amount');
            $table->timestamps();
        });

        Schema::create('charity_images', function (Blueprint $table) {
            $table->integer('charity_id')->unsigned()
                ->references('id')->on('charitys')
                ->onDelete('cascade');
            $table->integer('order_num');
            $table->string('url');
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::drop('users');
    }
}
