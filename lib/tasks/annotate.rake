namespace :annotate do
  desc "Annotate all models with attributes from schema."
  task models: :environment do
    `annotate --exclude tests,fixtures,factories,serializers`
  end
end
