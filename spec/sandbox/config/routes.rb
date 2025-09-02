Rails.application.routes.draw do
  get "mocked_table", to: "mocked_tables#show"
  post "mocked_table/bulk_action", to: "mocked_tables#bulk_action"
end
