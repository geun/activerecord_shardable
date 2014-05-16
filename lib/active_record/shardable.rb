module ActiveRecord
  module Shardable
    def database_configuration
      @database ||= Rails.configuration.database_configuration[Rails.env]
    end

    def create_shardable_table(table_name, schema_name = 'public', shard_id = 1)
      create_next_id_function(schema_name)
      set_bigint_primary_key(table_name, shard_id)
    end

    def create_next_id_function(schema_name)
      execute <<-EOD
        CREATE OR REPLACE FUNCTION #{schema_name}.next_id(In seq_name regclass, set_shard_id int, OUT result bigint) AS $$
        DECLARE
          our_epoch bigint := 1314220021721;
          seq_id bigint;
          now_millis bigint;
          shard_id int := set_shard_id;
          mod_key bigint := 1024;
        BEGIN
          SELECT nextval(seq_name) % mod_key INTO seq_id;
          SELECT FLOOR(EXTRACT(EPOCH FROM clock_timestamp()) * 1000) INTO now_millis;
          result := (now_millis - our_epoch) << 23;
          result := result | (shard_id << 10);
          result := result | (seq_id);
        END
        $$ LANGUAGE PLPGSQL;
      EOD
    end

    def set_bigint_primary_key(table_name, shard_id)
      execute <<-EOD
        CREATE SEQUENCE #{table_name}_id_seq
          INCREMENT 1
          MINVALUE 1
          MAXVALUE 9223372036854775807
          START 1
          CACHE 1;
        ALTER TABLE #{table_name}_id_seq
          OWNER TO #{database_configuration['username']};

        ALTER TABLE #{table_name} ADD CONSTRAINT #{table_name}_pkey PRIMARY KEY(id);
        ALTER TABLE #{table_name} ALTER COLUMN id SET DEFAULT next_id('#{table_name}_id_seq'::regclass, #{shard_id});
      EOD
    end

    def drop_next_id_function(schema_name = 'public')
      execute <<-EOD
        DROP FUNCTION #{schema_name}.next_id(In seq_name regclass, set_shard_id int, OUT result bigint)
      EOD
    end

    def drop_sequence(table_name)
      execute "DROP SEQUENCE #{table_name}_id_seq;"
    end

  end

end
