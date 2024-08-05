class AddCategoryToRecipes < ActiveRecord::Migration[7.1]
  def change
    add_column :recipes, :category, :string
  end
end
