class CarloadEnableZhparserExtension < ActiveRecord::Migration[5.0]
  def change
    enable_extension :zhparser
    execute 'create text search configuration zhparser (parser = zhparser);'
    execute 'alter text search configuration zhparser add mapping for n,v,a,i,e,l with simple;'
  end
end
