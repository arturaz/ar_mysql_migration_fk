# Adds ActiveRecord::Migration#add_fk method

class ActiveRecord::Migration
  # Source is parent end of the relationship. Target is child part.
  #
  # E.g. if galaxy has many stars, then galaxies table would be source and
  # stars table would be target.
  #
  def self.add_fk(source_table, target_table, options={})
    options = {
      :on_update => "CASCADE",
      :on_delete => "CASCADE",
      :source_key => "id",
      :target_key => "#{source_table.to_s.singularize}_id"
    }.merge(options)
    
    puts "-- FK #{source_table}" +
      "[#{options[:source_key]}] -> #{target_table}[#{options[:target_key]}] " +
      "(on delete: #{options[:on_delete]}, on update: #{options[:on_update]})"

    execute "ALTER TABLE `#{target_table}`
      ADD FOREIGN KEY (`#{options[:target_key]}`)
      REFERENCES `#{source_table}` (`#{options[:source_key]}`)
      ON DELETE #{options[:on_delete]}
      ON UPDATE #{options[:on_update]}"
  end

  def self.fk_name(table_name, column_name)
    sql = connection.
      select_one("SHOW CREATE TABLE `#{table_name}`")["Create Table"]
    match = sql.match(/CONSTRAINT `(.+?)` FOREIGN KEY \(`#{column_name}`\)/)
    raise "Cannot find #{column_name} FK on #{table_name}!" if match.nil?
    match[1]
  end

  def self.remove_fk(table_name, column_name)
    fk_name = fk_name(table_name, column_name)
    puts "-- FK removal from #{table_name}: #{column_name} (fk: #{fk_name})"
    connection.
      execute("ALTER TABLE `#{table_name}` DROP FOREIGN KEY `#{fk_name}`")
  end
end
