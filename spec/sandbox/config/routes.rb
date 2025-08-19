Rails.application.routes.draw do
  get "mocked_table", to: "mocked_tables#show"
end
