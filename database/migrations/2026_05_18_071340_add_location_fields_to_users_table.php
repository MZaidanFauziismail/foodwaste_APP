<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            if (! Schema::hasColumn('users', 'latitude')) {
                $table->decimal('latitude', 10, 7)->nullable();
            }

            if (! Schema::hasColumn('users', 'longitude')) {
                $table->decimal('longitude', 10, 7)->nullable();
            }

            if (! Schema::hasColumn('users', 'location_accuracy')) {
                $table->decimal('location_accuracy', 10, 2)->nullable();
            }

            if (! Schema::hasColumn('users', 'location_updated_at')) {
                $table->timestamp('location_updated_at')->nullable();
            }
        });
    }

    public function down(): void
    {
        $columns = [];

        if (Schema::hasColumn('users', 'latitude')) {
            $columns[] = 'latitude';
        }

        if (Schema::hasColumn('users', 'longitude')) {
            $columns[] = 'longitude';
        }

        if (Schema::hasColumn('users', 'location_accuracy')) {
            $columns[] = 'location_accuracy';
        }

        if (Schema::hasColumn('users', 'location_updated_at')) {
            $columns[] = 'location_updated_at';
        }

        if (! empty($columns)) {
            Schema::table('users', function (Blueprint $table) use ($columns) {
                $table->dropColumn($columns);
            });
        }
    }
};