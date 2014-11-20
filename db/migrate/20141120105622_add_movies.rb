class AddMovies < ActiveRecord::Migration

  def up
    create_table :movies do |t|
      t.string   :name
      t.float    :rating
      t.integer  :release_year

      t.timestamps
    end
  end

  def down
    drop_table :movies
  end

end
