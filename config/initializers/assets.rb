Rails.application.config.assets.paths << Carload::Engine.root.join('app/assets/plugins')
Rails.application.config.assets.precompile += %w( carload/dashboard.js carload/dashboard.css )
