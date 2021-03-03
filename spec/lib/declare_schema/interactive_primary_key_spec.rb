# frozen_string_literal: true

require 'rails'
begin
  require 'mysql2'
rescue LoadError
end

RSpec.describe 'DeclareSchema Migration Generator interactive primary key' do
  before do
    load File.expand_path('prepare_testapp.rb', __dir__)
  end

  context 'Using fields' do
    it "allows alternate primary keys" do
      class Foo < ActiveRecord::Base
        fields do
        end
        self.primary_key = "foo_id"
      end

      generate_migrations '-n', '-m'
      expect(Foo._defined_primary_key).to eq('foo_id')

      ### migrate from
      # rename from custom primary_key
      class Foo < ActiveRecord::Base
        fields do
        end
        self.primary_key = "id"
      end

      allow_any_instance_of(DeclareSchema::Support::ThorShell).to receive(:ask).with(/one of the rename choices or press enter to keep/) { 'id' }
      generate_migrations '-n', '-m'
      expect(Foo._defined_primary_key).to eq('id')

      nuke_model_class(Foo)

      ### migrate to

      if Rails::VERSION::MAJOR >= 5 && !defined?(Mysql2) # TODO TECH-4814 Put this test back for Mysql2
        # replace custom primary_key
        class Foo < ActiveRecord::Base
          fields do
          end
          self.primary_key = "foo_id"
        end

        allow_any_instance_of(DeclareSchema::Support::ThorShell).to receive(:ask).with(/one of the rename choices or press enter to keep/) { 'drop id' }
        generate_migrations '-n', '-m'
        expect(Foo._defined_primary_key).to eq('foo_id')

        ### ensure it doesn't cause further migrations

        # check no further migrations
        up = Generators::DeclareSchema::Migration::Migrator.run.first
        expect(up).to eq("")
      end
    end
  end

  context 'Using declare_schema' do
    it "allows alternate primary keys" do
      class Foo < ActiveRecord::Base
        declare_schema do
        end
        self.primary_key = "foo_id"
      end

      generate_migrations '-n', '-m'
      expect(Foo.primary_key).to eq('foo_id')

      ### migrate from
      # rename from custom primary_key
      class Foo < ActiveRecord::Base
        declare_schema do
        end
        self.primary_key = "id"
      end

      puts "\n\e[45m Please enter 'id' (no quotes) at the next prompt \e[0m"
      allow_any_instance_of(DeclareSchema::Support::ThorShell).to receive(:ask).with(/one of the rename choices or press enter to keep/) { 'id' }
      generate_migrations '-n', '-m'
      expect(Foo.primary_key).to eq('id')

      nuke_model_class(Foo)

      ### migrate to

      if Rails::VERSION::MAJOR >= 5 && !defined?(Mysql2) # TODO TECH-4814 Put this test back for Mysql2
        # replace custom primary_key
        class Foo < ActiveRecord::Base
          declare_schema do
          end
          self.primary_key = "foo_id"
        end

        puts "\n\e[45m Please enter 'drop id' (no quotes) at the next prompt \e[0m"
        allow_any_instance_of(DeclareSchema::Support::ThorShell).to receive(:ask).with(/one of the rename choices or press enter to keep/) { 'drop id' }
        generate_migrations '-n', '-m'
        expect(Foo.primary_key).to eq('foo_id')

        ### ensure it doesn't cause further migrations

        # check no further migrations
        up = Generators::DeclareSchema::Migration::Migrator.run.first
        expect(up).to eq("")
      end
    end
  end
end
